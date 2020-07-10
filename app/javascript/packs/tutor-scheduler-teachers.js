import $ from 'jquery';

$(document).on('turbolinks:load', function () {
  window.action_formatter = function(value) {
    return value.set_content_link + ' ' + value.set_feedback_link;
  };

  window.student_history_formatter = function(value, row) {
    if(row.student == '-')
      return value;
    return row.courses_history_link;
  };
});
