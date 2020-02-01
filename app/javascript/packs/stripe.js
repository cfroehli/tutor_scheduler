$(document).on("turbolinks:load", () => {
  var stripe = Stripe(stripe_pub_key);
  stripe.redirectToCheckout({ sessionId: stripe_session_id }).then(function(result) {alert(result.error.message);});
});
