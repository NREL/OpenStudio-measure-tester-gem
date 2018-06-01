require 'bundler/setup'
require 'openstudio_measure_tester'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'
  
  # print full backtrace for debugging
  config.full_backtrace = true

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  
  config.after(:each) do
    GC.start
  end
  
end
