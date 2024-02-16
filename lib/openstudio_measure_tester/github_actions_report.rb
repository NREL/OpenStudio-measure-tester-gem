# frozen_string_literal: true

# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

require 'json'
require 'rexml'

module OpenStudioMeasureTester
  class GithubActionsReport
    attr_reader :html

    # @param test_results_directory [String]: The directory
    def initialize(test_results_directory)
      @test_results_directory = test_results_directory
      file = File.read("#{@test_results_directory}/combined_results.json")
      @hash = JSON.parse(file)
    end

    def write_step_summary(msg)
      puts msg
      if !ENV['GITHUB_ACTIONS'].nil?
        File.write(ENV['GITHUB_STEP_SUMMARY'], "#{msg}\n", mode: 'a+')
      end
    end

    def hash_to_markdown(h, header0, header1)
      n0 = [h.keys.map(&:to_s).map(&:size).max, header0.size].max
      n1 = [h.values.map(&:to_s).map(&:size).max, header1.size].max

      content = [
        "| #{header0.ljust(n0)} | #{header1.ljust(n1)} |",
        "| " + "-" * n0 + " | " + "-" * n1 + " |",
      ] + h.map{|k, v| "| #{k.ljust(n0)} | #{v.to_s.ljust(n1)} |"}
      return content.join("\n")
    end

    def make_minitest_step_summary_table

      write_step_summary("## Minitest")
      write_step_summary("")

      total_tests = @hash['minitest']['total_tests']
      total_assertions = @hash['minitest']['total_assertions']
      total_errors = @hash['minitest']['total_errors']
      total_failures = @hash['minitest']['total_failures']
      total_skipped = @hash['minitest']['total_skipped']
      total_compatibility_errors = @hash['minitest']['total_compatibility_errors']
      total_load_errors = @hash['minitest']['total_load_errors'].count

      passed = total_tests - (total_failures + total_errors + total_skipped)
      pct = passed.to_f / (total_tests - total_skipped).to_f

      h = {
        'Total Tests' => total_tests,
        'Load Error' => total_load_errors,
        'Passed' => passed,
        'Success Rate' => '%.2f%%' % (pct * 100.0),
        'Failures' => total_failures,
        'Errors' => total_errors,
        'Skipped' => total_skipped,
        'Incompatible' => total_compatibility_errors,
        'Total Assertions' => total_assertions,
      }

      @minitest_summary_table = hash_to_markdown(h, "Metric", "Value")

      write_step_summary(@minitest_summary_table)
      write_step_summary("")
    end

    def make_minitest_annotations
      report_xmls = Dir["#{@test_results_directory}/minitest/reports/TEST-*.xml"]
      report_xmls.each do |report_xml|
        doc = REXML::Document.new(File.open(report_xml)).root
        testsuite_element = doc.elements['testsuite']
        filepath = testsuite_element.attributes['filepath']
        testsuite_element.elements.each('testcase') do |testcase|
          test_name = testcase.attributes['name']
          line = testcase.attributes['lineno'].to_i
          tested_class = testcase.attributes['classname']

          testcase.elements.each('failure') do |x|
            title = x.attributes['type']
            message = x.attributes['message']
            puts "::error file=#{filepath},line=#{line},endLine=#{line + 1},title=#{title}::#{tested_class}.#{test_name}: #{message}"
          end
          testcase.elements.each('error') do |x|
            title = x.attributes['type']
            message = x.attributes['message']
            puts "::error file=#{filepath},line=#{line},endLine=#{line + 1},title=#{title}::#{message}"
          end
          testcase.elements.each('skipped') do |x|
            title = x.attributes['type']
            message = x.attributes['message']
            puts "::warning file=#{filepath},line=#{line},endLine=#{line + 1},title=#{title}::#{message}"
          end
        end
      end
    end
  end
end
