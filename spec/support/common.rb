# frozen_string_literal: true

module CommonHelpers
  def filter_course_list_by(filter, filter_type)
    return unless filter

    click_on "#{filter_type.capitalize}: No filter"
    click_on filter
  end

  def click_on_course_time_slot_part(course, part)
    expect(page).to have_text("Choose a #{part}")
    within(".#{part}-selection") { click_on course.time_slot.send(part).to_s }
  end

  def open_course_reservation_page(course, teacher_filter = nil, language_filter = nil)
    visit courses_path
    filter_course_list_by(teacher_filter, :teacher)
    filter_course_list_by(language_filter, :language)
    %i[year month day].each { |part| click_on_course_time_slot_part(course, part) }
  end
end
