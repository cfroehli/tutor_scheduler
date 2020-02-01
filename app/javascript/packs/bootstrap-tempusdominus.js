import 'css/bootstrap-tempusdominus.scss';

import 'moment';
import 'tempusdominus-bootstrap-4';

document.addEventListener("turbolinks:load", () => {
  $("input.datetimepicker-input").each(function() {
    var picker_group = $($(this).data("target"));
    picker_group.datetimepicker({
      format: picker_group.data('date-format'),
      disabledTimeIntervals: [[moment({ h: 0 }), moment({ h: 7 })], [moment({ h: 23 }), moment({ h: 24 })]],
      icons: {
        time:     'far fa-clock',
        date:     'far fa-calendar',
        up:       'fas fa-arrow-up',
        down:     'fas fa-arrow-down',
        previous: 'fas fa-chevron-left',
        next:     'fas fa-chevron-right',
        today:    'far fa-calendar-check',
        clear:    'far fa-trash',
        close:    'far fa-times'
      } });
  });
});
