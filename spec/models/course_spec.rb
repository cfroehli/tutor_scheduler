# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Course, type: :model do
  let(:user) { create(:user) }
  let(:english) { create(:language, :english) }
  let(:spanish) { create(:language, :spanish) }
  let(:french) { create(:language, :french) }
  let(:teacher) { create(:teacher_with_courses, languages: [english, spanish]) }
  let!(:course) { teacher.courses.first }

  context 'when a course is added' do
    it 'is not in the past' do
      expect(Course.past).not_to include(course)
    end

    it 'is not signed up' do
      expect(Course.signed_up).not_to include(course)
    end

    it 'is not planned' do
      expect(Course.planned).not_to include(course)
    end

    it 'is not done' do
      expect(Course.done).not_to include(course)
    end

    it 'is in the future' do
      expect(Course.future).to match_array(teacher.courses)
    end

    it 'is open' do
      expect(Course.open).to match_array(teacher.courses)
    end

    it 'is accessible on the correct day' do
      teacher.courses.each do |course|
        t = course.time_slot
        expect(Course.on_day(t.year, t.month, t.day)).to include(course)
      end
    end

    it 'is available' do
      available_courses = Course.available
      expect(available_courses).to match_array(teacher.courses)

      years = teacher.courses
                     .map { |c| c.time_slot.year }
                     .uniq.sort
      expect(available_courses.years).to eql(years)

      years.each do |year|
        months = teacher.courses
                        .where('extract(year from time_slot) = ?', year)
                        .map { |c| c.time_slot.month }
                        .uniq.sort
        expect(available_courses.months(year)).to eql(months)

        months.each do |month|
          days = teacher.courses
                        .where('extract(year from time_slot) = ?', year)
                        .where('extract(month from time_slot) = ?', month)
                        .map { |c| c.time_slot.day }
                        .uniq.sort
          expect(available_courses.days(year, month)).to eql(days)
        end
      end
    end

    it 'has a teacher' do
      expect(Course.with_teacher(teacher)).to match_array(teacher.courses)
    end

    it 'has no student' do
      expect(Course.with_student(user)).not_to include(course)
    end

    it 'match the teacher languages' do
      teacher.languages.each do |teached_language|
        expect(Course.with_language(teached_language)).to match_array(teacher.courses)
      end
    end

    it 'does match other languages' do
      expect(Course.with_language(french)).not_to include(course)
    end

    it 'does not require feedback or content' do
      expect(Course.action_required).not_to include(course)
    end
  end

  def move_course_to_past
    course.update(time_slot: DateTime.current - 1.week)
  end

  context 'when a course expired' do
    before { move_course_to_past }

    it 'is in the past' do
      expect(Course.past).to match_array([course])
    end

    it 'is not in the future' do
      expect(Course.future).not_to include(course)
    end

    it 'is not done' do
      expect(Course.done).not_to include(course)
    end

    it 'is not planned' do
      expect(Course.planned).not_to include(course)
    end

    it 'is not available' do
      expect(Course.available).not_to include(course)
    end

    it 'does not require feedback or content' do
      expect(Course.action_required).not_to include(course)
    end
  end

  it 'reject reservation on unavailable languages' do
    result = nil
    expect { result = course.sign_up(user, french.id) }.to change(user, :remaining_tickets).by(0)
    expect(result).to be false
    expect(course.language).to be_nil
    expect(course.student).to be_nil
  end

  context 'when a course is reserved' do
    before { course.sign_up(user, english.id) }

    it 'reject a double reservation' do
      result = nil
      expect { result = course.sign_up(user, english.id) }.to change(user, :remaining_tickets).by(0)
      expect(result).to be false
    end

    it 'is not available' do
      expect(Course.available).not_to include(course)
    end

    it 'is planned' do
      expect(Course.planned).to match_array([course])
    end

    it 'is signed up' do
      expect(Course.signed_up).to match_array([course])
    end

    context 'and is terminated' do
      before { move_course_to_past }

      it 'require feedback and content' do
        expect(Course.action_required).to match_array([course])
      end

      it 'is not planned' do
        expect(Course.planned).not_to include(course)
      end

      it 'is done' do
        expect(Course.done).to match_array([course])
      end
    end
  end
end
