# frozen_string_literal: true

require 'ostruct'

# TODO: Products/Session code is mostly stripe api related => move to
# a thin stripe wrapper library

class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:on_event]
  skip_before_action :authenticate_user!, only: [:on_event]

  before_action :validate_event, only: %i[on_event]
  before_action :ensure_new_subscription_required, only: %i[create]

  STRIPE_EVENT_HANDLERS = Hash.new(:handle_unknown_event).merge!(
    {
      'checkout.session.completed' => :handle_checkout_session_completed,
      'invoice.payment_succeeded' => :handle_invoice_payment_succeeded,
    }
  )

  def on_event
    head method(STRIPE_EVENT_HANDLERS[@event.type]).call
  end

  def create
    item_type = params['stripeItemType']
    item_id = params['stripeItemId']

    session_data = create_session_data
    case item_type.to_sym
    when :product
      item_data = create_product(item_id)
    when :subscription
      item_data = create_subscription(item_id)
    else
      return :not_found
    end
    session_data.merge!(item_data)

    if current_user.stripe_user_id.blank?
      session_data['customer_email'] = current_user.email
    else
      session_data['customer'] = current_user.stripe_user_id
    end

    @session = Stripe::Checkout::Session.create(session_data)
  end

  def cancel_subscription
    _do_cancel_subscription
  end

  STRIPE_PRODUCTS = [
    ['1 Ticket',         1, 2000],
    ['3 Tickets Bundle', 3, 5000],
    ['5 Tickets Bundle', 5, 7500],
  ].freeze

  def self.setup_tickets_products
    product = Stripe::Product.create(
      {
        name: 'Course ticket',
        type: 'good',
        shippable: false,
        description: 'Can be used to reserve 1H course',
        attributes: %w[name lot_size],
      }
    )
    STRIPE_PRODUCTS.each do |name, hours, price|
      Stripe::SKU.create(
        {
          product: product.id,
          price: price,
          currency: 'jpy',
          inventory: { type: 'infinite' },
          attributes: { name: name, lot_size: hours },
        }
      )
    end
  end

  STRIPE_PLANS = [
    ['5 Tickets',   5,  7_000],
    ['7 Tickets',   7,  9_500],
    ['10 Tickets', 10, 12_000],
  ].freeze

  def self.setup_plans_products
    product = Stripe::Product.create(
      {
        name: 'Plan ticket',
        type: 'service',
        description: 'Can be used to reserve 1H course',
      }
    )
    STRIPE_PLANS.each do |name, hours, price|
      Stripe::Plan.create(
        {
          nickname: "#{name} per month",
          interval: 'month',
          currency: 'jpy',
          amount: price,
          product: product.id,
          metadata: { lot_size: hours },
        }
      )
    end
  end

  def self.setup_products
    self.setup_tickets_products
    self.setup_plans_products
  end

  def self.available_tickets_products
    Stripe::SKU
      .list
      .map do |sku|
        {
          id: sku.id,
          type: :product,
          name: sku.attributes.name,
          price: "#{sku.price}￥ (+税)",
          description: "Allow to reserve #{sku.attributes.lot_size} x 1H course.",
        }
      end
  end

  def self.available_plans_products
    Stripe::Plan
      .list
      .map do |plan|
        {
          id: plan.id,
          type: :subscription,
          name: plan.nickname,
          price: "#{plan.amount}￥",
          description: "Allow to reserve #{plan.metadata[:lot_size]} x 1H course. Automatically renewed, unused tickets are lost at the end of the period.",
        }
      end
  end

  def self.available_products
    [*self.available_tickets_products, *self.available_plans_products]
  end

  private

  def create_session_data
    {
      client_reference_id: current_user.id,
      payment_method_types: ['card'],
      success_url: url_for(controller: 'tickets', action: 'order_success'),
      cancel_url: url_for(controller: 'tickets', action: 'order_cancel'),
    }
  end

  def validate_event
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    begin
      @event = Stripe::Webhook.construct_event(request.body.read, sig_header, ENV['STRIPE_ENDPOINT_SECRET'])
    rescue JSON::ParserError
      head :bad_request
    rescue Stripe::SignatureVerificationError
      head :bad_request
    end
  end

  def ensure_new_subscription_required
    return if current_user.stripe_subscription_id.blank?

    if current_user.stripe_plan_id == params['stripeItemId']
      @session = OpenStruct.new({ id: nil, msg: 'This plan is already active' })
      render :create
    end

    _do_cancel_subscription
  end

  def _do_cancel_subscription
    current_subscription = current_user.stripe_subscription_id
    return unless current_subscription.present?

    Stripe::Subscription.delete(current_subscription)

    current_user.stripe_plan_id = nil
    current_user.stripe_subscription_id = nil
    current_user.save
  end

  def handle_checkout_session_completed
    checkout_session = @event.data.object

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

  def handle_invoice_payment_succeeded
    invoice_payment = @event.data.object

    item = invoice_payment.lines.data[0]

    user = User.find_by(stripe_subscription_id: item.subscription, stripe_plan_id: item.plan.id)
    return :not_found if user.nil?

    ticket_count = item.plan.metadata[:lot_size].to_i
    expiration = item.period[:end]
    expiration = Time.zone.at(expiration) unless expiration.nil?
    user.add_tickets(ticket_count, expiration)

    :accepted
  end

  def handle_unknown_event
    :bad_request
  end

  def create_product(item_id)
    stripe_sku = Stripe::SKU.retrieve(item_id)
    {
      mode: 'payment',
      line_items: [{
        name: stripe_sku.attributes[:name],
        amount: stripe_sku[:price],
        description: "Can be used to reserve #{stripe_sku.attributes[:lot_size]}x1H course",
        currency: 'jpy',
        quantity: 1,
      }],
      metadata: { lot_size: stripe_sku.attributes[:lot_size] },
    }
  end

  def create_subscription(item_id)
    stripe_plan = Stripe::Plan.retrieve(item_id)
    {
      mode: 'subscription',
      subscription_data: { items: [{ plan: stripe_plan.id, quantity: 1 }] },
      metadata: { lot_size: stripe_plan.metadata[:lot_size] },
    }
  end
end
