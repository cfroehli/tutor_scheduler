# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Student', type: :system, js: true do
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

  it 'can only see the teacher profile' do
    visit root_path
    expect(page).not_to have_text('Teaching')

    visit teacher_path(teacher.id)
    expect(page).to have_text('Teacher profile')
    expect(page).not_to have_text('Registering new courses slots')
    expect(page).not_to have_text('Action required')
    expect(page).not_to have_text('Current slots')
  end

  context 'when no remaining ticket' do
    before { user.use_ticket while user.remaining_tickets > 0 }

    it 'cant list available courses' do
      visit courses_path
      expect(page).to have_text('You need to buy at least one ticket to be able to reserve a course.')
    end
  end

  context 'when a ticket is available' do
    let(:course) { teacher.courses.order(time_slot: :asc).first }

    before do
      user.add_tickets(1)
      open_course_reservation_page(course)
    end

    it 'can reserve a course' do
      expect { click_on "[#{spanish.name}]", match: :first }
        .to change(user, :remaining_tickets).by(-1)
        .and change(ActionMailer::Base.deliveries, :count).by(2)
      expect(page).to have_text("Signed up for a [#{spanish.name}] course with [#{teacher.name}] at [#{course.time_slot.in_time_zone}].")
      course.reload
      expect(course.student).to eql(user)
      expect(course.language).to eql(spanish)
    end
  end

  context 'when displaying the dashboard' do
    before { visit root_path }

    it 'shows the remaining tickets' do
      expect(page).to have_text("Remaining tickets: #{user.remaining_tickets}")
    end

    it 'shows the tickets validity details' do
      user.tickets_validity.each do |expiration, remaining|
        expected_text = if expiration.nil?
                          "#{remaining} tickets without any date limit"
                        else
                          "#{remaining} tickets to use before #{expiration}"
                        end
        expect(page).to have_text(expected_text)
      end
    end
  end
end
