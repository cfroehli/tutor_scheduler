# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Student', type: :system, js: true do
  let(:user) { create(:user) }
  let(:english) { create(:language, :english) }
  let(:spanish) { create(:language, :spanish) }
  let!(:teacher) { create(:teacher_with_courses, languages: [english, spanish]) }
  let(:course) { teacher.courses.order(time_slot: :asc).first }

  let(:french) { create(:language, :french) }
  let(:italian) { create(:language, :italian) }
  let(:other_teacher) { create(:teacher_with_courses, languages: [french, italian]) }

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

  context 'when filtering available courses' do

    before do
      test_day = course.time_slot
      if other_teacher.courses.on_day(test_day.year, test_day.month, test_day.day).empty?
        other_teacher.courses.create(time_slot: course.time_slot, zoom_url: 'http://zoom.url')
      end
    end

    it 'can filter by teacher' do
      open_course_reservation_page(course, other_teacher.name)
      expect(page).not_to have_text(teacher.name)
      teacher.languages.each { |lang| expect(page).not_to have_text("[#{lang.name}]") }
      expect(page).to have_text(other_teacher.name)
      other_teacher.languages.each { |lang| expect(page).to have_text("[#{lang.name}]") }
    end

    it 'can filter by language' do
      open_course_reservation_page(course, nil, french.name)
      expect(page).not_to have_text(teacher.name)
      teacher.languages.each { |lang| expect(page).not_to have_text("[#{lang.name}]") }
      expect(page).to have_text(other_teacher.name)
      other_teacher.languages.each do |lang|
        if lang == french
          expect(page).to have_text("[#{lang.name}]")
        else
          expect(page).not_to have_text("[#{lang.name}]")
        end
      end
    end
  end

  context 'when teaching at the same time' do
    before do
      test_day = course.time_slot
      other_teacher_time_slots = other_teacher.courses
                                              .on_day(test_day.year, test_day.month, test_day.day)
                                              .map(&:time_slot)
      teacher_time_slots = teacher.courses
                                  .on_day(test_day.year, test_day.month, test_day.day)
                                  .map(&:time_slot)

      teacher_time_slots.each do |time_slot|
        unless other_teacher_time_slots.include? time_slot
          other_teacher.courses.create(time_slot: time_slot, zoom_url: 'http://zoom.url')
        end
      end

      other_teacher_time_slots.each do |time_slot|
        unless teacher_time_slots.include? time_slot
          teacher.courses.create(time_slot: time_slot, zoom_url: 'http://zoom.url')
        end
      end
      sign_in teacher.user
    end

    it 'cant sign up a course' do
      RSpec::Matchers.define_negated_matcher :not_change, :change
      open_course_reservation_page(course, other_teacher.name)
      expect { click_on "[#{french.name}]", match: :first }
        .to not_change(teacher.user, :remaining_tickets)
      expect(page).to have_text('Unable to sign up : You already have a teaching slot registered at the same time.')
    end
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
      open_course_reservation_page(course)
    end

    it 'can reserve a course' do
      expect do
        click_on "[#{spanish.name}]", match: :first
        expect(page).to have_text("Signed up for a [#{spanish.name}] course with [#{teacher.name}] at [#{course.time_slot.in_time_zone}].")
      end
        .to change(user, :remaining_tickets)
        .by(-1)
        .and change(ActionMailer::Base.deliveries, :count)
        .by(2)

      course.reload
      expect(course.student).to eql(user)
      expect(course.language).to eql(spanish)
    end

    it 'cant bypass ticket count verification' do
      RSpec::Matchers.define_negated_matcher :not_change, :change
      expect(page).to have_text("[#{spanish.name}]") # Load page
      user.use_ticket while user.remaining_tickets > 0 # Use available ticket on another tab
      expect do # then come back and click to sign up
        click_on "[#{spanish.name}]", match: :first
        expect(page).to have_text('You need a ticket to reserve a course.')
      end
        .to not_change(user, :remaining_tickets)
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
