import 'css/bootstrap-table.scss';

import 'bootstrap-table';

document.addEventListener("turbolinks:load", () => {
  $("table[data-source-form]").each(function() {
    var table = $(this);
    var form = $('#'+table.data('source-form'));
    table.bootstrapTable();
    form.on('ajax:success',
            function(event) {
              var detail = event.detail;
              table.bootstrapTable('load', detail[0]);
            });
    form.on('ajax:error',
            function(event) {
              console.error('Data binding failed.');
            });
  });

  $("table[data-url]").each(function() {
    $(this).bootstrapTable();
  });
});
