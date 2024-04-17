# frozen_string_literal: true

# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

require 'pathname'
require 'rexml'

module OpenStudioMeasureTester
  class MinitestResult
    attr_reader :error_status

    attr_reader :total_assertions
    attr_reader :total_errors
    attr_reader :total_failures
    attr_reader :total_skipped
    attr_reader :total_tests
    attr_reader :total_compatibility_errors
    attr_reader :measure_results
    attr_reader :summary

    def initialize(path_to_results)
      @path_to_results = Pathname.new(path_to_results)
      @junit_xml = @path_to_results / 'junit.xml'
      @has_results = @path_to_results.directory?
      @has_results ||= @junit_xml.file?

