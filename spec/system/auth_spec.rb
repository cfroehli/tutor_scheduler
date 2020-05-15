# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentication flow :', type: :system, js: true do
  let(:user) { build(:user) }

  context 'when user is not logged' do
    it 'will redirect to login page' do
      visit root_path
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
