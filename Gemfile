# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.2', '>= 6.0.2.1'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Use Haml templates
gem 'haml-rails', '~> 2.0.1'

# Reduce controller code (respond_to/respond_with)
gem 'responders', '~> 3.0.0'

# Authentification tools
gem 'devise', '~> 4.7.1'

# Impersonation
gem 'pretender', '~> 0.3.4'

# Roles/Authorization
gem 'pundit', '~> 2.1.0'
gem 'rolify', '~> 5.2.0'

# Image upload
gem 'carrierwave', '~> 2.1.0'
gem 'cloudinary', '~> 1.14.0'

# Inline css in email
gem 'roadie', '~> 4.0'

gem 'httparty', '~> 0.18.0'
gem 'stripe', '~> 5.22.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '~> 5.2.0'
  gem 'parallel_tests', '~> 2.32.0'
  gem 'rspec-rails', '~> 4.0.0'

  # stripe-mock
  gem 'puffing-billy', '~> 2.3.0'
  gem 'stripe-ruby-mock', github: 'cfroehli/stripe-ruby-mock', require: 'stripe_mock'
end

group :development do
  # Access an interactive console on exception pages or by calling
  # 'console' anywhere in the code.
  gem 'listen', '>= 3.2.1', '< 3.3'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Display info in browser (require browser extension)
  gem 'meta_request'
  gem 'pry'
  gem 'pry-doc'

  gem 'sgcop', github: 'SonicGarden/sgcop', require: false

  gem 'reek', require: false
end

group :test do
  gem 'simplecov', '~> 0.10', '< 0.18', require: false # Issue with 0.18 and cc-test-reporter

  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers', require: !ENV['USE_SELENIUM_CONTAINERS']
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
