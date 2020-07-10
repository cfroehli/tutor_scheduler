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
    let(:product) { ::TutorScheduler::Tickets::STRIPE_PRODUCTS.first }
    let(:plan) { ::TutorScheduler::Plans::STRIPE_PLANS.first }

    before { visit new_ticket_path }

    it 'displays the available plans/products' do
      StripeController.available_products.each do |p|
        expect(page).to have_text(p[:name])
      end
    end

    it 'can buy tickets' do
      RSpec::Matchers.define_negated_matcher :not_change, :change
      expect do
        click_on product[0].to_s
        session = retrieve_session_from_params_tracker
        expect { send_product_checkout_completed_event(session) }
          .to change(user, :remaining_tickets)
          .by(session['metadata']['lot_size'])
        user.reload
        expect(user.stripe_user_id).not_to be_nil
        visit order_success_tickets_path
        expect(page).to have_current_path(courses_path)
        expect(page).to have_text('Your order has been processed.')
      end.to not_change(user, :stripe_subscription_id).and not_change(user, :stripe_plan_id)
    end

    it 'reuse stripe customer info when available' do
      user.stripe_user_id = 'stripe_user_id'
      user.save
      click_on product[0].to_s
      session = retrieve_session_from_params_tracker
      expect(session['customer']).to eql(user.stripe_user_id)
    end

    it 'can almost buy a ticket, but no thanks' do
      RSpec::Matchers.define_negated_matcher :not_change, :change
      expect do
        click_on product[0].to_s
        retrieve_session_from_params_tracker
        expect { visit order_cancel_tickets_path }
          .to not_change(user, :remaining_tickets)
        expect(page).to have_current_path(courses_path)
        expect(page).to have_text('Your order has been cancelled.')
      end.to not_change(user, :stripe_subscription_id).and not_change(user, :stripe_plan_id)
    end

    it 'can start/stop a subscription' do
      expect(user.stripe_subscription_id).to be_nil
      expect(user.stripe_plan_id).to be_nil

      click_on "#{plan[0]} per month"
      session = retrieve_session_from_params_tracker

      expect { send_subscription_checkout_completed_event(session) }
        .to change(user, :remaining_tickets).by(0)

      user.reload
      expect(user.stripe_subscription_id).not_to be_nil
      expect(user.stripe_plan_id).not_to be_nil

      expect { send_subscription_payment_success_event(user.stripe_subscription_id) }
        .to change(user, :remaining_tickets).by(plan[1])

      visit new_ticket_path
      StripeController.available_products.each do |p|
        if p[:type] == :subscription
          expect(page).not_to have_text(p[:name])
        else
          expect(page).to have_text(p[:name])
        end
      end

      expect do
        click_on 'Cancel current plan'
        expect(accept_alert).to eq('Current plan cancelled')
        expect(page).to have_current_path(new_ticket_path)
        StripeController.available_products.each do |p|
          expect(page).to have_text(p[:name])
        end
      end.not_to change(user, :remaining_tickets)

      user.reload
      expect(user.stripe_subscription_id).to be_nil
      expect(user.stripe_plan_id).to be_nil
    end
  end
end
