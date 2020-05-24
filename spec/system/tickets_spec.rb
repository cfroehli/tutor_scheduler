# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tickets', type: :system, js: true, mock_server: true do
  let(:user) { create(:user) }

  before do
    @stripe_client = StripeMock.start_client
    StripeController.setup_products
    intercept_stripe_js_load
    sign_in user
  end

  after { StripeMock.stop_client(clear_server_data: true) }

  context 'when user access the tickets page' do
    before { visit new_ticket_path }

    it 'displays the available plans/products' do
      StripeController::STRIPE_PLANS.each do |p|
        expect(page).to have_text("#{p[0]} per month")
      end
      StripeController::STRIPE_PRODUCTS.each do |p|
        expect(page).to have_text(p[0].to_s)
      end
    end

    it 'can buy a ticket' do
      product = StripeController::STRIPE_PRODUCTS.first
      ticket_name = product[0]
      lot_size = product[1]
      click_on ticket_name
      expect(page).to have_selector('div#stripe_params_tracker', text: 'sessionId', visible: :hidden)
      event = StripeMock.mock_webhook_event('checkout.session.completed',
                                            {
                                              client_reference_id: user.id.to_s,
                                              metadata: { lot_size: lot_size },
                                            })
      headers = stripe_event_headers(event.to_json)
      expect do
        post on_event_stripe_index_path, params: event, headers: headers, as: :json
      end.to change(user, :remaining_tickets).by(lot_size)
    end
  end
end
