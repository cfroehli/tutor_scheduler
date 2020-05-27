if ENV['COVERAGE']
  SimpleCov.start 'rails' do
    add_filter 'app/channels'
    add_filter 'app/jobs'
    add_filter 'app/policies/application_policy.rb'
    # enable_coverage :branch # not avail in 0.17
  end
end
