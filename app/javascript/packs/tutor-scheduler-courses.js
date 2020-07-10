import $ from 'jquery';

$(document).on('turbolinks:load', function() {
  $('.dropdown-item').on('click', (event) => {
    window.location.href = event.target.href;
  });
});
