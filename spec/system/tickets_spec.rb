# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tickets', type: :system, js: true do
  let(:user) { create(:user) }

  before do
    @stripe_client = StripeMock.start_client
    StripeController.setup_products
    sign_in user
  end

  after { StripeMock.stop_client(clear_server_data: true) }

  context 'when user access the tickets page' do
    let(:product) { StripeController::STRIPE_PRODUCTS.first }
    let(:plan) { StripeController::STRIPE_PLANS.first }

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
      expect(user.stripe_subscription_id).to be_nil
      expect(user.stripe_plan_id).to be_nil

      click_on product[0].to_s
      session = retrieve_session_from_params_tracker
      expect do
        send_product_checkout_completed_event(session)
      end.to change(user, :remaining_tickets).by(session['metadata']['lot_size'])
      visit order_success_tickets_path
      expect(page).to have_current_path(courses_path)
      expect(page).to have_text('Your order has been processed.')

      expect(user.stripe_subscription_id).to be_nil
      expect(user.stripe_plan_id).to be_nil
    end

    it 'can almost buy a ticket, but no thanks' do
      expect(user.stripe_subscription_id).to be_nil
      expect(user.stripe_plan_id).to be_nil

      click_on product[0].to_s
      retrieve_session_from_params_tracker
      expect do
        visit order_cancel_tickets_path # Mimic stripe form cancel click
      end.to change(user, :remaining_tickets).by(0)
      expect(page).to have_current_path(courses_path)
      expect(page).to have_text('Your order has been cancelled.')

      expect(user.stripe_subscription_id).to be_nil
      expect(user.stripe_plan_id).to be_nil
    end

    xit 'can start a subscription' do
      expect(user.stripe_subscription_id).to be_nil
      expect(user.stripe_plan_id).to be_nil

      click_on "#{plan[0]} per month"
      session = retrieve_session_from_params_tracker
      expect do
        send_subscription_checkout_completed_event(session)
      end.to change(user, :remaining_tickets).by(0)

      expect(user.stripe_subscription_id).not_to be_nil
      expect(user.stripe_plan_id).not_to be_nil
    end
  end
end
