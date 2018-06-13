########################################################################################################################
#  OpenStudio(R), Copyright (c) 2008-2018, Alliance for Sustainable Energy, LLC. All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
#  following conditions are met:
#
#  (1) Redistributions of source code must retain the above copyright notice, this list of conditions and the following
#  disclaimer.
#
#  (2) Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#  following disclaimer in the documentation and/or other materials provided with the distribution.
#
#  (3) Neither the name of the copyright holder nor the names of any contributors may be used to endorse or promote
#  products derived from this software without specific prior written permission from the respective party.
#
#  (4) Other than as required in clauses (1) and (2), distributions in any form of modifications or other derivative
#  works may not use the "OpenStudio" trademark, "OS", "os", or any other confusingly similar designation without
#  specific prior written permission from Alliance for Sustainable Energy, LLC.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
#  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER, THE UNITED STATES GOVERNMENT, OR ANY CONTRIBUTORS BE LIABLE FOR
#  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
#  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
########################################################################################################################

module OpenStudioMeasureTester
  class MinitestResult
    attr_reader :error_status

    attr_reader :total_assertions
    attr_reader :total_errors
    attr_reader :total_failures
    attr_reader :total_skipped
    attr_reader :total_tests
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

      @measure_results = {}
      @summary = {}

      parse_results
      to_file
    end

    def parse_results
      Dir["#{@path_to_results}/reports/*.xml"].each do |file|
        puts "Parsing minitest report #{file}"
        doc = REXML::Document.new(File.open(file)).root

        # continue if doc is empty
        next unless doc

        measure_name = file.split('/')[-1].split('.')[0].split('-')[1].gsub /-?[tT]est\z/, ''

        mhash = {}
        mhash['tested_class'] = measure_name

        # Note: only 1 failure and 1 error possible per test
        testsuite_element = doc.elements['testsuite']
        errors, failures, skipped = parse_measure(testsuite_element)

        mhash['measure_tests'] = testsuite_element.attributes['tests'].to_i
        mhash['measure_assertions'] = testsuite_element.attributes['assertions'].to_i
        mhash['measure_errors'] = testsuite_element.attributes['errors'].to_i
        mhash['measure_failures'] = testsuite_element.attributes['failures'].to_i
        mhash['measure_skipped'] = testsuite_element.attributes['skipped'].to_i

        mhash['issues'] = { errors: errors, failures: failures, skipped: skipped }

        @measure_results[measure_name] = mhash

        @total_tests += mhash['measure_tests']
        @total_assertions += mhash['measure_assertions']
        @total_errors += mhash['measure_errors']
        @total_failures += mhash['measure_failures']
        @total_skipped += mhash['measure_skipped']
      end

      @error_status = true if @total_errors > 0
    end

    def to_file
      # save as a json and have something else parse it/plot it.

      @summary['test_directory'] = @path_to_results
      @summary['total_tests'] = @total_tests
      @summary['total_assertions'] = @total_assertions
      @summary['total_errors'] = @total_errors
      @summary['total_failures'] = @total_failures
      @summary['total_skipped'] = @total_skipped
      @summary['by_measure'] = @measure_results

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
          skipped << "Skipped test: " + testcase.elements['skipped'].attributes['type']
        end
      end

      return errors, failures, skipped
    end
  end
end
