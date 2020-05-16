# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Student usage:', type: :system, js: true do
  let(:user) { create(:user) }
  let(:english) { create(:language, :english) }
  let(:spanish) { create(:language, :spanish) }
  let!(:teacher) { create(:teacher_with_courses, languages: [english, spanish]) }

  before { sign_in user }

  it 'does not have access to admin section' do
    visit root_path
    expect(page).not_to have_text('Admin')
    visit admin_index_path
    expect(page).to have_text('You are not authorized to perform this action.')
    expect(page).to have_current_path(root_path)
  end

  context 'when no remaining ticket' do
    before { user.use_ticket while user.remaining_tickets > 0 }

    it 'cant list available courses' do
      visit courses_path
      expect(page).to have_text('You need to buy at least one ticket to be able to reserve a course.')
    end
  end

  context 'when a ticket is available' do
    before do
      user.add_tickets(1)
      teacher.user.add_tickets(1)
    end

    let(:course) { teacher.courses.first }

    def open_course_reservation_page
      visit courses_path
      click_on course.time_slot.year.to_s
      expect(page).to have_text('Choose a month')
      click_on course.time_slot.month.to_s
      expect(page).to have_text('Choose a day')
      click_on course.time_slot.day.to_s
    end

    it 'can reserve a course' do
      open_course_reservation_page
      expect { click_on '[Spanish]', match: :first }.to change(user, :remaining_tickets).by(-1)
      expect(page).to have_text("Signed up for a [Spanish] course with [#{teacher.name}] at [#{course.time_slot}].")
      course.reload
      expect(course.student).to eql(user)
      expect(course.language).to eql(spanish)
    end

    it 'cant reserve his own course' do
      sign_in teacher.user
      open_course_reservation_page
      expect { click_on '[Spanish]', match: :first }.to change(teacher.user, :remaining_tickets).by(0)
      expect(page).to have_text('Unable to sign up for your own course.')
      course.reload
      expect(course.student).to be_nil
      expect(course.language).to be_nil
    end
  end
end
