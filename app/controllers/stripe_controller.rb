# frozen_string_literal: true

require 'ostruct'

class StripeController < ApplicationController
  include ::TutorScheduler::Stripe

  before_action :ensure_new_subscription_required, only: %i[create]

  def create
    item_type = params['stripeItemType']
    item_id = params['stripeItemId']
    @session = create_stripe_session(item_type, item_id, :tickets)
  end

  def cancel_subscription
    _do_cancel_subscription
  end

  private

  def ensure_new_subscription_required
    return if current_user.stripe_subscription_id.blank?

    if current_user.stripe_plan_id == params['stripeItemId']
      @session = ::OpenStruct.new({ id: nil, msg: 'This plan is already active' })
      render :create
    end

    _do_cancel_subscription
  end

  def _do_cancel_subscription
    current_subscription = current_user.stripe_subscription_id
    return if current_subscription.blank?

    ::Stripe::Subscription.delete(current_subscription)

    current_user.stripe_plan_id = nil
    current_user.stripe_subscription_id = nil
    current_user.save
  end

  def handle_checkout_session_completed(event)
    checkout_session = event.data.object

    user = User.find(checkout_session.client_reference_id.to_i)
    return :not_found if user.nil?

    user.stripe_user_id = checkout_session.customer
    if checkout_session.subscription.blank?
      ticket_count = checkout_session.metadata[:lot_size].to_i
      user.add_tickets(ticket_count)
    else
      user.stripe_subscription_id = checkout_session.subscription
      user.stripe_plan_id = checkout_session.display_items[0].plan.id
    end
    user.save

    :accepted
  end

  def handle_invoice_payment_succeeded(event)
    invoice_payment = event.data.object
    item = invoice_payment.lines.data[0]

    user = User.find_by(stripe_subscription_id: item.subscription, stripe_plan_id: item.plan.id)
    return :not_found if user.nil?

    ticket_count = item.plan.metadata[:lot_size].to_i
    expiration = item.period[:end]
    expiration = Time.zone.at(expiration) unless expiration.nil?
    user.add_tickets(ticket_count, expiration)

    :accepted
  end
end
