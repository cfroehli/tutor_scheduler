import $ from 'jquery';
import { loadStripe } from '@stripe/stripe-js';

$(document).on("turbolinks:load", function() {
  window
    .fetch($('#stripe').data('new-url'), {
      method: "GET",
      headers: { "Content-Type": "application/json" }
    }).then(function(response) {
      return response.json();
    }).then(function(config) {
      const stripeLoader = loadStripe(config['pub_key']);
      stripeLoader.then(function(stripe) {
        function stripe_cancel(item) {
          window
            .fetch(config['cancel_subscription_url'], {
              method: "POST",
              headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content') },
              body: JSON.stringify(item)
            }).then(function(response) {
              alert('Current plan cancelled');
              window.location.reload();
            });
        }

        function stripe_checkout(item) {
          window
            .fetch(config['create_session_url'], {
              method: "POST",
              headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content') },
              body: JSON.stringify(item)
            }).then(function(response) {
              return response.json();
            }).then(function(session_data) {
              var session_id = session_data['id'];
              if (session_id != null) {
                stripe
                  .redirectToCheckout({ sessionId: session_id })
                  .then(function(result){
                    alert(result.error.message);
                  });
              } else {
                alert(session_data['msg']);
              }
            });
        };

        $('a[data-stripe-item-id]').on('click', (event) => {
          event.preventDefault();
          var item = $(event.currentTarget).data();
          if (item['stripeItemType'] == 'cancel') {
            stripe_cancel(item);
          } else {
            stripe_checkout(item);
          }
        });

      });
      $("#products").show();
    });
});
