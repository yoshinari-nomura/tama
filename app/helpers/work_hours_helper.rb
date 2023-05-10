module WorkHoursHelper
  def date_select_in_school_year(object_name, work_hour, year, options = {}, html_options = {})
    date = Date.new(year, 3)
    opts = Struct.new(:txt, :val)

    month_options = 12.times.map do
      date = date >> 1
      opts.new(date.strftime('%Y年%m月'), date.strftime('%Y-%m'))
    end

    selected_year_month = work_hour&.dtstart&.strftime("%Y-%m")
    selected_month = work_hour&.dtstart&.strftime("%m")
    selected_day = work_hour&.dtstart&.day

    is_valid_dtstart = validate_as_css_class_name(work_hour, :dtsart)
    is_valid_dtend = validate_as_css_class_name(work_hour, :dtend)

    dtstart_div = label_tag_with_validation(work_hour, 'work_hour', :dtstart) + tag.div(class: 'mb-3') {
      collection_select(object_name, 'dtstart(1i)', month_options, :val, :txt,
                        { selected: selected_year_month,
                          **options },
                        { id: "#{object_name}_dtstart_1i",
                          class: "form-select #{is_valid_dtstart}",
                          **html_options}) +
        hidden_field_tag("#{object_name}[dtstart(2i)]", selected_month,
                         { id: "#{object_name}_dtstart_2i",
                           autocomplete: 'off' }) +
        select_day(selected_day, {},
                   { id: "#{object_name}_dtstart_3i",
                     class: "form-select #{is_valid_dtstart}",
                     name: "#{object_name}[dtstart(3i)]",
                     **html_options }) +
        "日" +
        time_select(object_name, :dtstart,
                    { default: work_hour.dtstart,
                      start_hour: 7,
                      end_hour: 21,
                      minute_step: 5,
                      ignore_date: true,
                      **options },
                    class: "form-select #{is_valid_dtstart}",
                    **html_options) +
        "〜"
    }

    dtend_div = label_tag_with_validation(work_hour, 'work_hour', :dtend) + tag.div(class: 'mb-3') {
      time_select(object_name, :dtend,
                  { default: work_hour.dtend,
                    start_hour: 7,
                    end_hour: 21,
                    minute_step: 5,
                    **options },
                  class: "form-select #{is_valid_dtend}",
                  **html_options)
    }

    tag.div(class: %w[row rails-bootstrap-forms-date-select]) {
      tag.div(class: 'col-auto') { dtstart_div } +
        tag.div(class: 'col-auto') { dtend_div }
    }
  end
end
