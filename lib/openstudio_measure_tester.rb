# frozen_string_literal: true

# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

require 'openstudio'

require 'pp'
require 'rexml/document'
require 'minitest'
require 'simplecov'

begin
  require 'git'
rescue LoadError => e
  puts 'Could not load git, will not be able to report git information'
end

# override the default at_exit call
SimpleCov.at_exit do
end

# Override the minitest autorun, to, well, not autorun
def Minitest.autorun; end

# Rubocop loads a lot of objects, anyway to minimize would be nice.
require 'rubocop'

require_relative 'openstudio_measure_tester/core_ext'
require_relative 'openstudio_measure_tester/version'
require_relative 'openstudio_measure_tester/openstudio_style'
require_relative 'openstudio_measure_tester/minitest_result'
require_relative 'openstudio_measure_tester/coverage'
require_relative 'openstudio_measure_tester/rubocop_result'
require_relative 'openstudio_measure_tester/openstudio_testing_result'
require_relative 'openstudio_measure_tester/dashboard'
require_relative 'openstudio_measure_tester/runner'

require_relative 'openstudio_measure_tester/rake_task'

# Set the encoding to UTF-8. OpenStudio Docker images do not have this set by default
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

module OpenStudioMeasureTester
  # No action here. Most of this will be rake_tasks at the moment.
end

class Minitest::Test
  def teardown
    before = ObjectSpace.count_objects
    GC.start
    after = ObjectSpace.count_objects
    delta = {}
    before.each { |k, v| delta[k] = v - after[k] if after.key? k }
    # puts "GC Delta: #{delta}"
  end
end
