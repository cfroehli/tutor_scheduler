module CommonHelpers
  def open_course_reservation_page(course, teacher_filter = nil, language_filter = nil)
    visit courses_path
    if teacher_filter
      click_on 'Teacher: No filter'
      click_on teacher_filter
    end

    if language_filter
      click_on 'Language: No filter'
      click_on language_filter
    end

    expect(page).to have_text('Choose a year')
    within('.year-selection') { click_on course.time_slot.year.to_s }
    expect(page).to have_text('Choose a month')
    within('.month-selection') { click_on course.time_slot.month.to_s }
    expect(page).to have_text('Choose a day')
    within('.day-selection') { click_on course.time_slot.day.to_s }
  end
end
