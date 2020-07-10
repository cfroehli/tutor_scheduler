# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentication flow:', type: :system, js: true do
  let(:user) { create(:user) }

  context 'when user is not logged' do
    before { visit root_path }

    it 'will redirect to login page' do
      expect(page).to have_current_path(new_user_session_path)
    end

    it 'can login with correct credentials' do
      fill_in 'user_login', with: user.username
      fill_in 'user_password', with: user.password
      click_on 'Log in'
      expect(page).to have_current_path(root_path)
    end

    it 'cant login with incorrect password' do
      fill_in 'user_login', with: user.username
      fill_in 'user_password', with: 'WrongPassword'
      click_on 'Log in'
      expect(page).to have_text('Invalid Login or password.')
      expect(page).to have_current_path(new_user_session_path)
    end

    it 'cant login with incorrect username' do
      fill_in 'user_login', with: 'UnknownUser'
      fill_in 'user_password', with: 'UnknownUserPassword'
      click_on 'Log in'
      expect(page).to have_text('Invalid Login or password.')
      expect(page).to have_current_path(new_user_session_path)
    end
  end

  context 'when user is logged' do
    before do
      sign_in user
      visit root_path
    end

    it 'will show the dashboard' do
      expect(page).to have_current_path(root_path)
    end

    it 'logout is allowed' do
      click_on 'Logout', match: :first
      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
