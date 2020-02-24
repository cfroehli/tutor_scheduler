$(document).on('turbolinks:load', function() {
  var start_day_picker = $('#start_day_picker');
  var end_day_picker = $('#end_day_picker');
  start_day_picker.datetimepicker('useCurrent', false);

  start_day_picker.on("change.datetimepicker", function (e) {
    end_day_picker.datetimepicker('minDate', e.date);
  });

  end_day_picker.on("change.datetimepicker", function (e) {
    start_day_picker.datetimepicker('maxDate', e.date);
  });

  window.stats_text_formatter = function(value) {
    return value.text;
  };

  window.stats_style_formatter = function(value) {
    var cls = 'bg-danger';
    if(value.ratio === 0 ) cls = 'bg-secondary';
    else if(value.ratio <= 0.5) cls = 'bg-success';
    else if(value.ratio <= 0.85) cls = 'bg-warning';
    return { classes: cls };
  };
});
