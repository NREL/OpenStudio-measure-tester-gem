# frozen_string_literal: true

# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

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
      @path_to_results = path_to_results
      @error_status = false
      @total_tests = 0
      @total_assertions = 0
      @total_errors = 0
      @total_failures = 0
      @total_skipped = 0
      @total_compatibility_errors = 0
      @total_loaded = true
      @total_load_errors = []

      @measure_results = {}
      @summary = {}

      parse_results
      to_file
    end

    def parse_results
      # use the compatibility file to find the measure name and other files
      Dir["#{@path_to_results}/compatibility/*.json"].each do |file|
        puts "Parsing compatibility report #{file}"
        json_data = JSON.parse(File.read(file), symbolize_names: true)

        # Test if the measure has already been parse, if so, then continue
        next if @measure_results.key?(json_data[:measure_name])

        mhash = {}
        mhash[:tested_class] = json_data[:measure_name]
        mhash[:openstudio_version] = json_data[:openstudio_version]
        mhash[:measure_min_version] = json_data[:measure_min_version]
        mhash[:measure_max_version] = json_data[:measure_max_version]
        mhash[:loaded] = json_data[:loaded]
        if json_data[:load_errors].nil?
          mhash[:load_errors] = []
        else
          mhash[:load_errors] = json_data[:load_errors]
        end

        # initialize a bunch of data
        mhash[:measure_compatibility_errors] = json_data[:compatible] ? 0 : 1
        mhash[:measure_tests] = 0
        mhash[:measure_assertions] = 0
        mhash[:measure_errors] = 0
        mhash[:measure_failures] = 0
        mhash[:measure_skipped] = 0
        mhash[:issues] = {
          errors: [],
          failures: [],
          skipped: [],
          compatibility_error: json_data[:compatible] ? 0 : 1
        }

        # find the report XML - if it exists
        report_xmls = Dir["#{@path_to_results}/reports/TEST-#{json_data[:measure_name]}*.xml"]
        if report_xmls.count == 1
          puts "Parsing minitest report #{report_xmls[0]}"
          doc = REXML::Document.new(File.open(report_xmls[0])).root

          if doc
            # Note: only 1 failure and 1 error possible per test
            testsuite_element = doc.elements['testsuite']
            errors, failures, skipped = parse_measure(testsuite_element)

            mhash[:measure_tests] = testsuite_element.attributes['tests'].to_i
            mhash[:measure_assertions] = testsuite_element.attributes['assertions'].to_i
            mhash[:measure_errors] = testsuite_element.attributes['errors'].to_i
            mhash[:measure_failures] = testsuite_element.attributes['failures'].to_i
            mhash[:measure_skipped] = testsuite_element.attributes['skipped'].to_i

            mhash[:issues][:errors] = errors
            mhash[:issues][:failures] = failures
            mhash[:issues][:skipped] = skipped
          end
        else
          # There are more than one XMLs or there are no XML
          # No XMLs is typically because the measure was not applicable to then version of OpenStudio
        end

        @measure_results[mhash[:tested_class]] = mhash

        @total_tests += mhash[:measure_tests]
        @total_assertions += mhash[:measure_assertions]
        @total_errors += mhash[:measure_errors]
        @total_failures += mhash[:measure_failures]
        @total_skipped += mhash[:measure_skipped]
        @total_compatibility_errors += mhash[:measure_compatibility_errors]
        @total_loaded &&= mhash[:loaded]
        @total_load_errors.concat(mhash[:load_errors])
      end

      @error_status = true if @total_errors > 0
    end

    def to_file
      # save as a json and have something else parse it/plot it.

      @summary[:test_directory] = @path_to_results
      @summary[:total_tests] = @total_tests
      @summary[:total_assertions] = @total_assertions
      @summary[:total_errors] = @total_errors
      @summary[:total_failures] = @total_failures
      @summary[:total_skipped] = @total_skipped
      @summary[:total_compatibility_errors] = @total_compatibility_errors
      @summary[:total_loaded] = @total_loaded
      @summary[:total_load_errors] = @total_load_errors
      @summary[:by_measure] = @measure_results

      # pp @summary

      FileUtils.mkdir "#{@path_to_results}/" unless Dir.exist? "#{@path_to_results}/"
      File.open("#{@path_to_results}/minitest.json", 'w') do |file|
        file << JSON.pretty_generate(summary)
      end
    end

    private

    def parse_measure(testsuite_element)
      errors = []
      failures = []
      skipped = []

      testsuite_element.elements.each('testcase') do |testcase|
        if testcase.elements['error']
          errors << testcase.elements['error']
        elsif testcase.elements['failure']
          failures << testcase.elements['failure']
        elsif testcase.elements['skipped']
          skipped << 'Skipped test: ' + testcase.elements['skipped'].attributes['type']
        end
      end

      return errors, failures, skipped
    end
  end
end
