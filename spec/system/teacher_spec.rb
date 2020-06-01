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

  context 'when displaying the course reservation page' do
    let(:course) { teacher.courses.order(time_slot: :asc).first }

    before do
      teacher.user.add_tickets(1)
      open_course_reservation_page(course)
    end

    it 'cant reserve his own course' do
      # TODO: hide own course from reservation page and ensure in
      # this test we cant reserve by forging a POST request
      expect { click_on "[#{spanish.name}]", match: :first }
        .to change(teacher.user, :remaining_tickets).by(0)
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
      page.attach_file(Rails.root.join('spec/fixtures/spintop.jpg'), make_visible: true)
      click_on 'Submit'
      expect(page).to have_current_path(teacher_path(teacher.id))
      expect(page).to have_text("This is #{teacher.name}'s presentation.")
    end

    it 'can declare new slots' do
      fill_in 'zoom_url', with: 'http://zoom.url/course'
      fill_in 'days', with: (Date.current + 11.days).strftime('%Y-%m-%d')
      click_on 'None selected'
      expect(page).to have_text('Afternoon')
      click_on 'Afternoon'
      expect do
        click_on 'Add'
        expect(page).to have_selector(:link_or_button, 'Add') # Force wait to bg request completion
      end.to change(teacher.courses, :count).by(4)
      expect(page).to have_current_path(teacher_path(teacher.id))
      expect(page).to have_text('Courses were successfully created.')
    end
  end

  context 'when a course is signed up' do
    let(:student) { create(:user) }
    let(:course) { teacher.courses.order(time_slot: :asc).first }

    before { course.sign_up(student, english.id) }

    it 'can access the student history' do
      visit teacher_path(teacher.id)
      within('#current_slots') { click_on student.username }
      expect(page).to have_current_path(courses_history_user_path(student.id))
    end

    context 'when past' do
      before do
        course.update(time_slot: course.time_slot - 5.days)
        visit teacher_path(teacher.id)
      end

      it 'is displayed in the action required list' do
        within('#past_slots') do
          expect(page).to have_text(course.student.username)
          expect(page).to have_text(course.language.name)
        end
      end

      it 'feedback/content can be added' do
        within('#past_slots') do
          row = find('td', text: course.student.username).ancestor('tr')
          row.all('td').last.find('a', text: 'Content').click
        end
        expect(page).to have_current_path(edit_course_path(course.id))
        fill_in 'content-area', with: "#{course.id} content"
        click_on 'Submit'
        expect(page).to have_text('Course was successfully updated.')

        visit teacher_path(teacher.id)
        within('#past_slots') do
          row = find('td', text: course.student.username).ancestor('tr')
          row.all('td').last.find('a', text: 'Feedback').click
        end
        expect(page).to have_current_path(edit_course_path(course.id))
        fill_in 'feedback-area', with: "#{course.id} feedback"
        expect do
          click_on 'Submit'
          expect(page).to have_text('Course was successfully updated.')
        end.to change(ActionMailer::Base.deliveries, :count).by(1)
        expect(page).to have_current_path(edit_course_path(course.id))

        sign_in course.student
        visit root_path
        expect(page).to have_text("#{course.id} feedback")
      end
    end
  end
end
