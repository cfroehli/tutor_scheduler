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

    it 'can impersonate a user' do
      user_name = wannabe_teacher.username
      expect(page).to have_text("Sign in as #{user_name}")
      click_on user_name, match: :first
      expect(page).to have_current_path(root_path)
      expect(page).not_to have_text('Admin')
      expect(page).to have_text("#{user_name}'s dashboard")
      expect(page).to have_text("You are currently signed in as [#{user_name}] - Cancel impersonation")
      click_on 'Cancel impersonation'
      expect(page).to have_text("#{admin.username}'s dashboard")
      expect(page).not_to have_text('You are currently signed in as')
      expect(page).to have_text('Admin')
    end

    it 'can register a new language' do
      language_name = french.name
      within('#inactive-languages') { expect(page).not_to have_text(language_name) }
      within('#active-languages') do
        expect(page).to have_text(teacher.name)
        expect(page).not_to have_text(language_name)
      end
      select teacher.user.username, from: 'user'
      select language_name, from: 'language'
      expect do
        click_on 'Add'
        within('#active-languages') do
          expect(page).to have_text(teacher.name)
          expect(page).to have_text(language_name)
        end
      end.to change(teacher.languages, :count).by(1)
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
      expect do
        click_on 'Add'
        within('#active-languages') do
          expect(page).to have_text(wannabe_teacher.teacher_profile.name)
          expect(page).to have_text(language_name)
        end
      end.to change(Teacher, :count).by(1)
    end

    it 'can enable/disable a language' do
      language_name = english.name
      within('#inactive-languages') { expect(page).not_to have_text(language_name) }
      within('#active-languages') do
        row = find('td', text: language_name).ancestor('tr')
        row.all('td').last.find('i.fas.fa-toggle-on').click
      end
      within('#inactive-languages') { expect(page).to have_text(language_name) }
      within('#inactive-languages') do
        row = find('td', text: language_name).ancestor('tr')
        row.all('td').last.find('i.fas.fa-toggle-off').click
      end
      within('#inactive-languages') { expect(page).not_to have_text(language_name) }
    end
  end
end
