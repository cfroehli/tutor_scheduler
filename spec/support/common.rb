module CommonHelpers
  def open_course_reservation_page(course)
    visit courses_path
    expect(page).to have_text('Choose a year')
    within('.year-selection') { click_on course.time_slot.year.to_s }
    expect(page).to have_text('Choose a month')
    within('.month-selection') { click_on course.time_slot.month.to_s }
    expect(page).to have_text('Choose a day')
    within('.day-selection') { click_on course.time_slot.day.to_s }
  end
end
