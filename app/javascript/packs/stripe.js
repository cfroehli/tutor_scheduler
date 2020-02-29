// import Stripe from 'stripe';
import $ from 'jquery';

$(document).on("turbolinks:load", function() {
  function stripe_checkout(items) {
    const stripe = new Stripe($('#stripe').data('pub-key'));
    stripe
      .redirectToCheckout({        
        customerEmail: $('#stripe').data('email'),
        clientReferenceId: $('#stripe').data('id').toString(),
        items: items,
        successUrl: $('#stripe').data('success-url'),
        cancelUrl: $('#stripe').data('cancel-url') })      
      .then(function(result){
        alert(result.error.message);
      });
  };

  $('a[data-item-type="product"]').on('click', (event) => {
    event.preventDefault();
    const items = [{'sku': $(event.currentTarget).data('item-id'), quantity: 1}];
    stripe_checkout(items);
  });

  $('a[data-item-type="subscription"]').on('click', (event) => {
    event.preventDefault();
    const items = [{'plan': $(event.currentTarget).data('item-id'), quantity: 1}];
    stripe_checkout(items);
  }); 
  
  $("#products").show();
});
