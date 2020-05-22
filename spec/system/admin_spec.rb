# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin', type: :system, js: true do
  let(:admin) { create(:admin) }
  let!(:wannabe_teacher) { create(:user) }
  let(:english) { create(:language, :english) }
  let!(:french) { create(:language, :french) }
  let!(:spanish) { create(:language, :spanish) }
  let!(:teacher) { create(:teacher_with_courses, languages: [english]) }

  before { sign_in admin }

  context 'when displaying the main page' do
    it 'have access to admin section' do
      visit root_path
      expect(page).to have_text('Admin')
      click_on 'Admin', match: :first
      expect(page).to have_current_path(admin_index_path)
      expect(page).to have_text('Administration')
    end
  end

  context 'when displaying the admin page' do
    before { visit admin_index_path }

    it 'can register a new language' do
      language_name = french.name
      within('#inactive-languages') { expect(page).not_to have_text(language_name) }
      within('#active-languages') do
        expect(page).to have_text(teacher.name)
        expect(page).not_to have_text(language_name)
      end
      select teacher.user.username, from: 'user'
      select language_name, from: 'language'
      expect {
        click_on 'Add'
        within('#active-languages') do
          expect(page).to have_text(teacher.name)
          expect(page).to have_text(language_name)
        end
      }.to change(teacher.languages, :count).by(1)
    end

    it 'can register a new teacher' do
      language_name = spanish.name
      within('#inactive-languages') { expect(page).not_to have_text(language_name) }
      within('#active-languages') do
        expect(page).not_to have_text(wannabe_teacher.username)
        expect(page).not_to have_text(language_name)
      end
      select wannabe_teacher.username, from: 'user'
      select language_name, from: 'language'
      expect {
        click_on 'Add'
        within('#active-languages') do
          expect(page).to have_text(wannabe_teacher.teacher_profile.name)
          expect(page).to have_text(language_name)
        end
      }.to change(Teacher, :count).by(1)
    end
  end
end
