# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Teacher', type: :system, js: true do
  let(:english) { create(:language, :english) }
  let(:spanish) { create(:language, :spanish) }
  let!(:teacher) { create(:teacher_with_courses, languages: [english, spanish]) }

  before { sign_in teacher.user }

  context 'when displaying the main page' do
    it 'does not have access to admin section' do
      visit root_path
      expect(page).not_to have_text('Admin')
      visit admin_index_path
      expect(page).to have_text('You are not authorized to perform this action.')
      expect(page).to have_current_path(root_path)
    end

    it 'have access to the teacher section' do
      visit root_path
      click_on 'Teaching'
      expect(page).to have_current_path(teacher_path(teacher.id))
    end
  end

  # TODO: regroup & move out
  def open_course_reservation_page
    visit courses_path
    click_on course.time_slot.year.to_s
    expect(page).to have_text('Choose a month')
    click_on course.time_slot.month.to_s
    expect(page).to have_text('Choose a day')
    click_on course.time_slot.day.to_s
  end

  context 'when displaying the course reservation page' do
    let(:course) { teacher.courses.order(time_slot: :asc).first }

    before do
      teacher.user.add_tickets(1)
      open_course_reservation_page
    end

    it 'cant reserve his own course' do
      # TODO: hide own course from reservation page and ensure in
      # this test we cant reserve by forging a POST request
      expect { click_on "[#{spanish.name}]", match: :first }.to change(teacher.user, :remaining_tickets).by(0)
      expect(page).to have_text('Unable to sign up for your own course.')
      course.reload
      expect(course.student).to be_nil
      expect(course.language).to be_nil
    end
  end

  context 'when displaying the teacher section' do
    before { visit teacher_path(teacher.id) }

    it 'can edit his profile' do
      find('.card i.fa.fa-edit').click
      expect(page).to have_text('Update teaching profile')
      fill_in 'teacher-presentation-area', with: "This is #{teacher.name}'s presentation."
      click_on 'Submit'
      expect(page).to have_current_path(teacher_path(teacher.id))
      expect(page).to have_text("This is #{teacher.name}'s presentation.")
    end

    it 'can declare new slots' do
      fill_in 'days', with: (Date.current + 11.days).strftime("%Y-%m-%d")
      click_on 'None selected'
      click_on 'Afternoon'
      fill_in 'zoom_url', with: 'http://zoom.url/course'
      expect do
        click_on 'Add'
        expect(page).to have_selector(:link_or_button, 'Add') # Force wait to bg request completion
      end.to change(teacher.courses, :count).by(4)
      expect(page).to have_current_path(teacher_path(teacher.id))
      expect(page).to have_text('Courses were successfully created.')
    end
  end


end
