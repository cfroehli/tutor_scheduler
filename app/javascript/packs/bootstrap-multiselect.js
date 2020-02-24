import $ from 'jquery';

import 'css/bootstrap-multiselect.scss';
import 'bootstrap-multiselect';

$(document).on('turbolinks:load', function() {
  $('select[multiple="multiple"]').multiselect({
    numberDisplayed: 0,
    includeSelectAllOption: true,
    includeResetOption: true,
    includeResetDivider: true,
    enableClickableOptGroups: true
  });

  //$('.multiselect-container div.checkbox').each(function (index) {
  //      var id = 'multiselect-' + index,
  //          $input = $(this).find('input');
  //      $(this).find('label').attr('for', id);
  //      $input.attr('id', id);
  //      $input.detach();
  //      $input.prependTo($(this));
  //      $(this).click(function (e) {
  //          e.stopPropagation();
  //      });
  //  });

});
