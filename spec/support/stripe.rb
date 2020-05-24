module StripeTestHelpers
  def stripe_event_headers(event_json)
    timestamp = Time.now
    secret = ENV['STRIPE_ENDPOINT_SECRET']
    signature = Stripe::Webhook::Signature.compute_signature(timestamp, event_json, secret)
    scheme = Stripe::Webhook::Signature::EXPECTED_SCHEME
    { "Stripe-Signature": Stripe::Webhook::Signature.generate_header(timestamp, signature, scheme: scheme) }
  end

  # TODO: disable stub when stripe-mock is running in live mode
  def intercept_stripe_js_load
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

    Billy.proxy.stub('https://js.stripe.com:443/v3')
         .and_return(content_type: 'application/javascript', body: fake_stripe_script)
  end
end
