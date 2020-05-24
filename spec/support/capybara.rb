Capybara.default_max_wait_time = ENV['TRAVIS'] ? 30 : 5

puts "Capybara.default_max_wait_time: #{Capybara.default_max_wait_time}"

if ENV['USE_SELENIUM_CONTAINERS']
  Capybara.register_driver :custom_selenium_driver do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: {
        args: %W[
                 enable-features=NetworkService,NetworkServiceInProcess
                 ignore-certificate-errors
                 proxy-server=#{Billy.proxy.host}:#{Billy.proxy.port}
                 proxy-bypass-list=127.0.0.1;localhost;#{Socket.gethostname}
                 no-sandbox
                 disable-gpu
                 disable-dev-shm-usage
                 window-size=1280x1024
                 headless
                ]
      }
    )
    Capybara::Selenium::Driver.new(
      app,
      url: 'http://selenium-server:4444/wd/hub',
      browser: :remote,
      desired_capabilities: capabilities,
      clear_local_storage: true,
      clear_session_storage: true
    )
  end
  Capybara.server_host = '0.0.0.0'
  Capybara.server_port = 9090 + ENV['TEST_ENV_NUMBER'].to_i
else
  Capybara.register_driver :custom_selenium_driver do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--enable-features=NetworkService,NetworkServiceInProcess')
    options.add_argument('--ignore-certificate-errors')
    options.add_argument("--proxy-server=#{Billy.proxy.host}:#{Billy.proxy.port}")
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-gpu')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--window-size=1280x1024')
    options.add_argument('--headless')

    ::Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      options: options,
      clear_local_storage: true,
      clear_session_storage: true
    )
  end
end
Capybara.javascript_driver = :custom_selenium_driver

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
      driven_by Capybara.javascript_driver
    end
  end
end
