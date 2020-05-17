# frozen_string_literal: true

require 'test_helper'

class CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:toto)
    sign_in @user
  end

  test 'should get index' do
    get courses_url
    assert_response :success
  end

  test 'should display course' do
    get courses_url
    assert_response :success
  end
end
