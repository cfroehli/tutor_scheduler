module CommonHelpers
  def open_course_reservation_page(course)
    visit courses_path
    click_on course.time_slot.year.to_s
    expect(page).to have_text('Choose a month')
    click_on course.time_slot.month.to_s
    expect(page).to have_text('Choose a day')
    click_on course.time_slot.day.to_s
  end
end
