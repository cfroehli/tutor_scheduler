// import Stripe from 'stripe';
import $ from 'jquery';

$(document).on("turbolinks:load", function() {
  function stripe_checkout(stripe_session_id) {
    var stripe = new Stripe(window.STRIPE_PUB_KEY);
    stripe
      .redirectToCheckout({ sessionId: stripe_session_id })
      .then((result) => alert(result.error.message));
  };
  
  $("a[data-product]").on('click', (event) => {
    window.fetch(window.CHECKOUT_TICKETS_PATH + '/?product_id=' + event.currentTarget.dataset.product)
      .then(response => response.json())
      .then((json) => stripe_checkout(json.session_id));
    event.returnValue = false;
  });
  
  $("#products").show();
});
