# frozen_string_literal: true

class StripeController < ApplicationController
  include ::TutorScheduler::Stripe

  before_action :ensure_new_subscription_required, only: %i[create]

  def create
    item_type = params['stripeItemType']
    item_id = params['stripeItemId']
    @session = create_stripe_session(item_type, item_id, :tickets)
  end

  private

  def ensure_new_subscription_required
    return unless current_user.has_stripe_subscription

    head :bad_request
  end

  def save_checkout_to_user_account(user, checkout_session)
    user.stripe_user_id = checkout_session.customer

    subscription = checkout_session.subscription
    if subscription.present?
      user.set_stripe_subscription(subscription, checkout_session.display_items[0].plan.id)
    else
      user.add_tickets(checkout_session.metadata[:lot_size].to_i)
    end
  end

  def handle_checkout_session_completed(event)
    checkout_session = event.data.object

    user = User.find(checkout_session.client_reference_id.to_i)
    return :not_found unless user

    save_checkout_to_user_account(user, checkout_session)
    :accepted
  end

  def save_plan_to_user_account(user, plan, period_end)
    ticket_count = plan.metadata[:lot_size].to_i
    user.add_tickets(ticket_count, period_end)
  end

  def handle_invoice_payment_succeeded(event)
    invoice_payment = event.data.object
    item = invoice_payment.lines.data[0]
    plan = item.plan

    user = User.find_by(stripe_subscription_id: item.subscription, stripe_plan_id: plan.id)
    return :not_found unless user

    save_plan_to_user_account(user, plan, item.period[:end])
    :accepted
  end
end
