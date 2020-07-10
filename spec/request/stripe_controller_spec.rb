# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeController, type: :request do
  let(:user) { create(:user) }
  let(:plan) { TutorScheduler::Plans.available.first }
  let(:product) { TutorScheduler::Tickets.available.first }

  before do
    login_as user, scope: :user
    @stripe_client = StripeMock.start_client
    StripeController.setup_products
  end

  after { StripeMock.stop_client(clear_server_data: true) }

  it 'reject a double subscription' do
    user.set_stripe_subscription('fake_subscription_id', plan[:id])
    user.save

    post stripe_index_path, params: { stripeItemType: plan[:type], stripeItemId: plan[:id] }, as: :json
    expect(response).to have_http_status(:bad_request)
  end

  it 'reject a counterfeit event' do
    post stripe_index_path, params: { stripeItemType: product[:type], stripeItemId: product[:id] }, as: :json
    session_id = JSON.parse(response.body)['id']
    session = Stripe::Checkout::Session.retrieve(session_id)
    with_stripe_endpoint_secret('wrong_secret_endpoint') do
      send_product_checkout_completed_event(session)
    end
    expect(response).to have_http_status(:bad_request)
  end

  it 'reject an unknown event' do
    event = StripeMock.mock_webhook_event('checkout.session.completed', {})
    event['type'] = 'not_a_stripe_event'
    headers = stripe_event_headers(event.to_json)
    post on_event_stripe_index_path, params: event, headers: headers, as: :json
    expect(response).to have_http_status(:bad_request)
  end
end
