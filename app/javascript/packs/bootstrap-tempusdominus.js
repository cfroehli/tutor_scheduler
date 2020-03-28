import $ from 'jquery';

import 'tempusdominus-bootstrap-4';

$(document).on("turbolinks:load", function() {
  $(".datetimepicker-input").each(function() {
    var picker_group = $($(this).data('target'));
    picker_group.datetimepicker({
      debug: true,
      icons: {
        time:     'far fa-clock',
        date:     'far fa-calendar',
        up:       'fas fa-arrow-up',
        down:     'fas fa-arrow-down',
        previous: 'fas fa-chevron-left',
        next:     'fas fa-chevron-right',
        today:    'far fa-calendar-check',
        clear:    'far fa-trash',
        close:    'far fa-times' },
      disabledHours: [0, 1, 2, 3, 4, 5, 6, 23, 24 ]
    });
  });
});
