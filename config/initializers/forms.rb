module ActionView
  module Helpers
    ## TODO replace default date_select by html using tempus lib so we
    ## can just write f.date_select as usual
    ##class FormBuilder
    ##  def date_select(method, options = {}, html_options = {})
    ##    existing_date = @object.nil? ? DateTime.now : @object.send(method)
    ##    formatted_date = existing_date.to_date.strftime("%F") if existing_date.present?
    ##    @template.content_tag(:div, :class => "input-group date") do
    ##      text_field(method, :value => formatted_date, :class => "form-control datepicker-input", :"data-date-format" => "YYYY-MM-DD") +
    ##        @template.content_tag(:div,
    ##                              @template.content_tag(:div,
    ##                                                    @template.content_tag(:i, "", :class => "fas fa-calendar"),
    ##                                                    :class => "input-group-text"),
    ##                              :class => "input-group-append"
    ##    end
    ##  end
    ##
    ##  def datetime_select(method, options = {}, html_options = {})
    ##    existing_date = @object.nil? ? DateTime.now : @object.send(method)
    ##    formatted_time = existing_time.to_time.strftime("%F %I:%M %p") if existing_time.present?
    ##    @template.content_tag(:div, :class => "input-group datetime") do
    ##      text_field(method, :value => formatted_time, :class => "form-control datetimepicker-input", :"data-date-format" => "YYYY-MM-DD hh:mm A") +
    ##      @template.content_tag(:div, @template.content_tag(:i, "", :class => "fas fa-calendar") ,:class => "input-group-text")
    ##    end
    ##  end
    ##end
  end
end
