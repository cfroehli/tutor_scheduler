import 'stripe';
//    %script{src: "https://js.stripe.com/v3/", defer: "true", 'data-turbolinks-track': "reload"}

$(document).on("turbolinks:load", function() {
  function stripe_checkout(stripe_session_id) {
    var stripe = new Stripe("#{Rails.configuration.stripe[:publishable_key]}");
    stripe
      .redirectToCheckout({ sessionId: stripe_session_id })
      .then((result) => alert(result.error.message));
  };
  
  $("a[data-product]").on('click', (event) => {
    fetch("#{checkout_tickets_path}/?product_id=" + event.currentTarget.dataset.product)
      .then(response => response.json())
      .then((json) => stripe_checkout(json.session_id));
    event.returnValue = false;
  });
  
  $("#products").show();
});
