require "bundler/gem_tasks"
require "rspec/core/rake_task"

require 'openstudio_measure_tester/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)

OpenStudioMeasureTester::RakeTask.new

task :default => :spec
