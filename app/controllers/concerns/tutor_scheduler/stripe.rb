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
    )

    def create_stripe_session(item_type, item_id, redirect_controller)
      session_data = ::TutorScheduler::Stripe.create_stripe_session_data(
        current_user,
        url_for(controller: redirect_controller, action: 'order_success'),
        url_for(controller: redirect_controller, action: 'order_cancel')
      )
      case item_type.to_sym
      when :product
        item_data = ::TutorScheduler::Tickets.create(item_id)
      when :subscription
        item_data = ::TutorScheduler::Plans.create(item_id)
      else
        return :not_found
      end
      session_data.merge!(item_data)

      if current_user.stripe_user_id.blank?
        session_data['customer_email'] = current_user.email
      else
        session_data['customer'] = current_user.stripe_user_id
      end

      ::Stripe::Checkout::Session.create(session_data)
    end

    def on_event
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      begin
        event = ::Stripe::Webhook.construct_event(request.body.read, sig_header, ENV['STRIPE_ENDPOINT_SECRET'])
        head method(STRIPE_EVENT_HANDLERS[event.type]).call(event)
      rescue JSON::ParserError
        head :bad_request
      rescue ::Stripe::SignatureVerificationError
        head :bad_request
      end
    end

    def handle_unknown_event(event)
      logger.warning("Unhandled event: #{event.fetch('type', 'Unknown event type')}")
      :bad_request
    end

    def handle_checkout_session_completed(event)
      raise 'handle_checkout_session_completed NYI'
    end

    def handle_invoice_payment_succeeded(event)
      raise 'handle_invoice_payment_succeeded NYI'
    end

    def self.create_stripe_session_data(user, success_url, cancel_url)
      {
        client_reference_id: user.id,
        payment_method_types: ['card'],
        success_url: success_url,
        cancel_url: cancel_url,
      }
    end
  end
end
