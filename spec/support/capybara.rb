Capybara.default_max_wait_time = 15 if ENV['TRAVIS']

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    if ENV['USE_SELENIUM_CONTAINERS']
      # Seems system tests don't enable javascript_driver when js: true as
      # documented, manually select the driver here until fixed
      driven_by Capybara.javascript_driver

      # Tell remote chrome to hit the test server here
      host! "http://#{Socket.gethostname}:#{Capybara.server_port}"
    else
      driven_by :selenium, using: :headless_chrome, screen_size: [1280, 1024]
    end
  end
end
