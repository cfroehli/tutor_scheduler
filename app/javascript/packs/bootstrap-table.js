import 'css/bootstrap-table.scss';

import 'bootstrap-table';

$(document).on("turbolinks:load", () => {
  $("table[data-source-form]").each(() => {
    var table = $(this);
    table.bootstrapTable();

    var form = $('#'+table.data('source-form'));
    form.on('ajax:success',
            (event) => {
              var detail = event.detail;
              table.bootstrapTable('load', detail[0]);
            });
    form.on('ajax:error',
            (event) => {
              console.error('Data binding failed.');
            });
  });
});

$(document).on("turbolinks:render", () => {
  $("[data-toggle='table']").bootstrapTable();
});
