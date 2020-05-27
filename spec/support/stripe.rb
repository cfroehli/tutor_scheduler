Billy.configure do |config|
  config.proxy_host = ENV.fetch('RAILS_TEST_PROXY_HOST') { '127.0.0.1' }
end

fake_stripe_script = <<~SCRIPT_END
  (function() {
    var stripe_params_tracker = document.createElement('div');
    stripe_params_tracker.id = 'stripe_params_tracker';
    stripe_params_tracker.style.display = 'none';
    document.body.appendChild(stripe_params_tracker);
    window.Stripe = function(args) {
      return {
        redirectToCheckout:
          function(params) {
            while (stripe_params_tracker.firstChild) {
              stripe_params_tracker.removeChild(stripe_params_tracker.firstChild);
            }
            var text_params = document.createTextNode(JSON.stringify(params));
            stripe_params_tracker.appendChild(text_params);
          } }; }; })();
SCRIPT_END

# TODO: maybe disable stub when stripe-mock is running in live mode?
puts 'Installing stripeJS stub'
Billy.proxy.stub('https://js.stripe.com:443/v3')
     .and_return(content_type: 'application/javascript',
                 body: fake_stripe_script)

Billy.proxy.reset_cache
puts "Proxing external requests to #{Billy.proxy.host}:#{Billy.proxy.port}"

module StripeTestHelpers
  def stripe_event_headers(event_json)
    timestamp = Time.current
    secret = ENV['STRIPE_ENDPOINT_SECRET']
    signature = Stripe::Webhook::Signature.compute_signature(timestamp, event_json, secret)
    scheme = Stripe::Webhook::Signature::EXPECTED_SCHEME
    { "Stripe-Signature": Stripe::Webhook::Signature.generate_header(timestamp, signature, scheme: scheme) }
  end

  def retrieve_session_from_params_tracker
    expect(page).to have_selector('div#stripe_params_tracker', text: 'sessionId', visible: :hidden)
    session_data = find('div#stripe_params_tracker', visible: :hidden)['innerHTML']
    session_id = JSON.parse(session_data)['sessionId']
    Stripe::Checkout::Session.retrieve(session_id)
  end

  def create_customer(session)
    customer = Stripe::Customer.create(
      {
        email: session['customer_email'],
        source: StripeMock.generate_card_token,
        currency: 'jpy',
      }
    )
    customer.id
  end

  def get_or_create_customer(session)
    session['customer'] || create_customer(session)
  end

  def send_event(event_name, params)
    event = StripeMock.mock_webhook_event(event_name, params)
    headers = stripe_event_headers(event.to_json)
    post on_event_stripe_index_path, params: event, headers: headers, as: :json
  end

  def send_product_checkout_completed_event(session) # rubocop:disable Metric/MethodLength
    send_event(
      'checkout.session.completed',
      {
        customer: get_or_create_customer(session),
        client_reference_id: session.client_reference_id,
        display_items: session.line_items.map do |item|
          {
            type: 'custom',
            custom: {
              description: item['description'],
              name: item['name'],
              images: nil,
            },
            amount: item['amount'],
            quantity: item['quantity'],
            currency: item['currency'],
          }
        end.to_a,
        mode: session.mode,
        payment_intent: session.payment_intent,
        payment_method_types: session.payment_method_types,
        metadata: session.metadata,
      }
    )
  end

  def send_subscription_checkout_completed_event(session) # rubocop:disable Metric/MethodLength
    customer = get_or_create_customer(session)
    items = session['subscription_data']['items']

    subscription = Stripe::Subscription.create(
      {
        customer: customer,
        items: items.map do |item|
          stripe_plan = Stripe::Plan.retrieve(item.plan)
          {
            plan: stripe_plan.id,
            quantity: item.quantity,
          }
        end.to_a,
      }
    )

    send_event(
      'checkout.session.completed',
      {
        customer: customer,
        client_reference_id: session['client_reference_id'],
        display_items: subscription.items.data,
        mode: session.mode,
        subscription: subscription.id,
        payment_intent: session.payment_intent,
        payment_method_types: session.payment_method_types,
        metadata: session.metadata,
      }
    )
  end

  def send_subscription_payment_success_event(subscription_id)
    subscription = Stripe::Subscription.retrieve(subscription_id)
    invoice = Stripe::Invoice.upcoming(customer: subscription['customer'])
    event_object = invoice.to_hash
    event_object[:lines][:data][0][:subscription] = subscription['id']
    send_event('invoice.payment_succeeded', event_object)
  end
end
