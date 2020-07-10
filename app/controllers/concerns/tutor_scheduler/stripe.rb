module TutorScheduler
  module Stripe
    extend ActiveSupport::Concern

    included do
      skip_before_action :verify_authenticity_token, only: [:on_event]
      skip_before_action :authenticate_user!, only: [:on_event]
    end

    class_methods do
      def setup_products
        ::TutorScheduler::Tickets.setup
        ::TutorScheduler::Plans.setup
      end

      def available_products
        [*::TutorScheduler::Tickets.available,
         *::TutorScheduler::Plans.available]
      end
    end

    STRIPE_EVENT_HANDLERS = Hash.new(:handle_unknown_event).merge!(
      {
        'checkout.session.completed' => :handle_checkout_session_completed,
        'invoice.payment_succeeded' => :handle_invoice_payment_succeeded,
      }
    ).freeze

    STRIPE_ITEM_CREATORS = {
      product: ::TutorScheduler::Tickets,
      subscription: ::TutorScheduler::Plans,
    }.freeze

    def create_stripe_session(item_type, item_id, redirect_controller)
      return :not_found if item_id.blank?

      item_creator = STRIPE_ITEM_CREATORS.fetch(item_type.to_sym)
      return :not_found unless item_creator

      session_data = ::TutorScheduler::Stripe.create_stripe_session_data(
        current_user,
        url_for(controller: redirect_controller, action: 'order_success'),
        url_for(controller: redirect_controller, action: 'order_cancel')
      )

      session_data.merge!(item_creator.create(item_id))
      ::TutorScheduler::Stripe.add_customer_info(current_user, session_data)
      ::Stripe::Checkout::Session.create(session_data)
    end

    def cancel_subscription
      return unless current_user.has_stripe_subscription

      ::Stripe::Subscription.delete(current_user.stripe_subscription_id)
      current_user.set_stripe_subscription(nil, nil)
      current_user.save
    end

    def on_event
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      begin
        event = ::Stripe::Webhook.construct_event(request.body.read, sig_header, ENV['STRIPE_ENDPOINT_SECRET'])
        head method(STRIPE_EVENT_HANDLERS[event.type]).call(event)
      rescue ::Stripe::SignatureVerificationError, JSON::ParserError
        head :bad_request
      end
    end

    def handle_unknown_event(event)
      logger.warn("Unhandled event: #{event.type}")
      :bad_request
    end

    def self.create_stripe_session_data(user, success_url, cancel_url)
      {
        client_reference_id: user.id,
        payment_method_types: ['card'],
        success_url: success_url,
        cancel_url: cancel_url,
      }
    end

    def self.add_customer_info(user, session_data)
      stripe_user_id = user.stripe_user_id
      if stripe_user_id.blank?
        session_data['customer_email'] = user.email
      else
        session_data['customer'] = stripe_user_id
      end
    end
  end
end
