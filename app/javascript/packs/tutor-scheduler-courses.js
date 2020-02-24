$(document).on('turbolinks:load', function() {
  $('.dropdown-item').on('click', (event) => {
    location.href = event.target.href;
  });
});
