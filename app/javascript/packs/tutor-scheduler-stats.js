import $ from 'jquery';
import moment from 'moment';

$(document).on('turbolinks:load', function() {
  var month_start = moment().startOf('month');
  var month_end = moment().endOf('month');

  var start_day_picker = $('#start_day_picker');
  start_day_picker.datetimepicker('maxDate', month_end);
  start_day_picker.datetimepicker('date', month_start);

  var end_day_picker = $('#end_day_picker');
  end_day_picker.datetimepicker('minDate', month_start);
  end_day_picker.datetimepicker('date', month_end);

  var hourly_stats = $('#hourly_stats');

  start_day_picker.on("change.datetimepicker", function(event) {
    end_day_picker.datetimepicker('minDate', event.date);
    hourly_stats.bootstrapTable('refresh');
  });

  end_day_picker.on("change.datetimepicker", function(event) {
    start_day_picker.datetimepicker('maxDate', event.date);
    hourly_stats.bootstrapTable('refresh');
  });

  window.hourly_stats_query_params = function(params) {
    params['order'] = undefined;
    params['start_date'] = $(start_day_picker).datetimepicker('date').format('YYYY-MM-DD');
    params['end_date'] = $(end_day_picker).datetimepicker('date').format('YYYY-MM-DD');
    return params;
  };

  var year_picker = $('#year_picker');
  var monthly_stats_details = $('#monthly_stats_details');
  var weekly_stats_details = $('#weekly_stats_details');

  var stats_details = $('#stats_details');

  var teachers_stats = $('#teachers_stats');
  teachers_stats.on("click-cell.bs.table", function(field, value, row, element) {
    var cell = element[value];
    if (cell.ratio != -1) {
      stats_details.data('stats_source', teachers_stats);
      teachers_stats.data('stats_month', value);
      teachers_stats.data('stats_item', element[0]);
      monthly_stats_details.bootstrapTable('refreshOptions', { 'url': teachers_stats.data('monthly-stats-url') });
      weekly_stats_details.bootstrapTable('refreshOptions', { 'url': teachers_stats.data('weekly-stats-url') });
      var year = year_picker.datetimepicker('date').format('YYYY');
      stats_details.find('.modal-title').text(element[0] + ' statistics - ' + value + '/' + year);
      stats_details.modal('show');
    }
  });

  year_picker.on("change.datetimepicker", function(e) {
    teachers_stats.bootstrapTable('refresh');
  });

  var languages_stats = $('#languages_stats');
  languages_stats.on("click-cell.bs.table", function(field, value, row, element) {
    var cell = element[value];
    if (cell.ratio != -1) {
      stats_details.data('stats_source', languages_stats);
      languages_stats.data('stats_month', value);
      languages_stats.data('stats_item', element[0]);
      monthly_stats_details.bootstrapTable('refreshOptions', { 'url': languages_stats.data('monthly-stats-url') });
      weekly_stats_details.bootstrapTable('refreshOptions', { 'url': languages_stats.data('weekly-stats-url') });
      var year = year_picker.datetimepicker('date').format('YYYY');
      stats_details.find('.modal-title').text(element[0] + ' statistics - ' + value + '/' + year);
      stats_details.modal('show');
    }
  });

  year_picker.on("change.datetimepicker", function(e) {
    languages_stats.bootstrapTable('refresh');
  });

  stats_details.on('shown.bs.modal', function () {
    monthly_stats_details.bootstrapTable('resetView');
    weekly_stats_details.bootstrapTable('resetView');
  });

  window.stats_query_params = function(params) {
    params['order'] = undefined;
    params['year'] = year_picker.datetimepicker('date').format('YYYY');
    return params;
  };

  window.stats_details_query_params = function(params) {
    params = window.stats_query_params(params);
    var stats_source = stats_details.data('stats_source');
    params['month'] = stats_source.data('stats_month');
    params['item'] = stats_source.data('stats_item');
    return params;
  };

  window.stats_text_formatter = function(value) {
    return value.text == null ? 'N/A' : value.text;
  };

  window.stats_style_formatter = function(value) {
    var cls = 'bg-danger';
    if(value.ratio < 0) cls = 'bg-secondary';
    else if(value.ratio <= 50) cls = 'bg-success';
    else if(value.ratio <= 85) cls = 'bg-warning';
    return { classes: cls };
  };
});
