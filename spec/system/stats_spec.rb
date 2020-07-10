# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Stats', type: :system, js: true do
  let(:user) { create(:user) }
  let(:english) { create(:language, :english) }
  let(:spanish) { create(:language, :spanish) }
  let!(:teacher) { create(:teacher_with_courses, languages: [english, spanish]) }

  before do
    sign_in user
    visit stats_path
  end

  context 'when displaying statistics' do
    it 'can limit to a date range' do
      time_slots = teacher.courses.map(&:time_slot)
      fill_in 'start_day', with: time_slots.min.strftime('%Y-%m-%d')
      fill_in 'start_day', with: time_slots.max.strftime('%Y-%m-%d')
      # TODO: check stats values
    end

    it 'can display teacher statistics' do
      within('#teachers_stats') do
        all('td.bg-success').first.click
      end
      within('#stats_details') do
        expect(page).to have_text("#{teacher.name} statistics")
        # TODO: check stats values
      end
    end

    it 'can display langugage statistics' do
      within('#languages_stats') do
        all('td.bg-success').first.click
      end
      within('#stats_details') do
        expect(page).to have_text("#{english.name} statistics")
        # TODO: check stats values
      end
    end
  end
end
