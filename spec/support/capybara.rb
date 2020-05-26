Capybara.default_max_wait_time = ENV['TRAVIS'] ? 30 : 5
puts "WebServer timeout set to #{Capybara.default_max_wait_time}s"

Capybara.server_host = ENV.fetch('RAILS_TEST_WEBSERVER_HOST') { '127.0.0.1' }
Capybara.server_port = ENV.fetch('RAILS_TEST_WEBSERVER_PORT') { 9090 } + ENV['TEST_ENV_NUMBER'].to_i
puts "Test server will start on #{Capybara.server_host}:#{Capybara.server_port}"

if ENV['USE_SELENIUM_CONTAINERS']
  selenium_hub_host = ENV.fetch('SELENIUM_HUB_HOST') { 'selenium-server' }
  selenium_hub_port = ENV.fetch('SELENIUM_HUB_PORT') { 4444 }

  Capybara.register_driver :custom_selenium_driver do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: {
        args: %W[
          enable-features=NetworkService,NetworkServiceInProcess
          ignore-certificate-errors
          proxy-server=#{Billy.proxy.host}:#{Billy.proxy.port}
          proxy-bypass-list=127.0.0.1;localhost;#{Capybara.server_host}
          no-sandbox
          disable-gpu
          disable-dev-shm-usage
          window-size=1280,1024
          headless
        ],
      }
    )
    Capybara::Selenium::Driver.new(
      app,
      url: "http://#{selenium_hub_host}:#{selenium_hub_port}/wd/hub",
      browser: :remote,
      desired_capabilities: capabilities,
      clear_local_storage: true,
      clear_session_storage: true
    )
  end
  puts "Remote selenium on #{selenium_hub_host}:#{selenium_hub_port}"
else
  Capybara.register_driver :custom_selenium_driver do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--enable-features=NetworkService,NetworkServiceInProcess')
    options.add_argument('--ignore-certificate-errors')
    options.add_argument("--proxy-server=#{Billy.proxy.host}:#{Billy.proxy.port}")
    options.add_argument("--proxy-bypass-list=127.0.0.1;localhost;#{Capybara.server_host}")
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-gpu')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--window-size=1280,1024')
    options.add_argument('--headless')

    ::Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      options: options,
      clear_local_storage: true,
      clear_session_storage: true
    )
  end
  puts 'Local selenium'
end
Capybara.javascript_driver = :custom_selenium_driver

RSpec.configure do |config|
  config.before(:each, type: :system) { driven_by :rack_test }

  config.before(:each, type: :system, js: true) do
    # Seems system tests don't enable javascript_driver when js: true as
    # documented, manually select the driver here until fixed
    driven_by Capybara.javascript_driver

    # Tell chrome to hit the test server here
    host! "http://#{Capybara.server_host}:#{Capybara.server_port}"
  end
end
