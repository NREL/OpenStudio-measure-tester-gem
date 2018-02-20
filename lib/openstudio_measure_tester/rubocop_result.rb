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
  class RubocopResult
    attr_reader :error_status

    attr_reader :total_issues
    attr_reader :total_errors
    attr_reader :total_info
    attr_reader :total_warnings
    attr_reader :total_files
    attr_reader :tested_files
    attr_reader :file_issues
    attr_reader :summary

    def initialize(path_to_results)
      @path_to_results = path_to_results
      @error_status = false
      @total_issues = 0
      @tested_files = 0
      @total_errors = 0
      @total_warnings = 0
      @total_info = 0
      @file_issues = 0

      @measure_results = {}
      @summary = {}

      parse_results
      to_file

    end

    def parse_results
      # needs rescue
      Dir["#{@path_to_results}/rubocop-results.xml"].each do |file|
        puts "Parsing Rubocop report #{file}"
        hash = Hash.from_xml(File.read(file))

        files = ""
        @total_files = hash['checkstyle']['file'].length
        @total_issues = 0
        @total_info = 0
        @total_warnings = 0
        @file_issues = 0

        @summary = hash

        hash['checkstyle']['file'].each do |key,value|
            file = key['name']
            files += file + "\n"

            if key['error']

              if key['error'].class == Array
                @file_issues = key['error'].length
                key['error'].each do |s|
                  if s['severity'] === "info"
                    @total_info += 1
                  elsif s['severity'] === "warning"
                    @total_warnings += 1
                  end
                end
              end

              if key['error'].class == Hash
                @file_issues = 1
                if key['error']['severity'] === "info"
                  @total_info += 1
                elsif key['error']['severity'] === "warning"
                  @total_warnings += 1
                end
              end

              @total_issues += @file_issues

            end

        end

        puts "tested files (#{total_files}):\n#{files}"
        puts "total files: #{total_files}"
        puts "total issues: #{total_issues} (#{total_info} info, #{total_warnings} warnings)"        

        #measure_name = file.split('/')[-1].split('.')[0].split('-')[1]

        #mhash = {}

        #mhash['tested_class'] = measure_name
        #mhash['measure_tests'] = hash['testsuite']['tests'].to_i
        #mhash['measure_assertions'] = hash['testsuite']['assertions'].to_i
        #mhash['measure_errors'] = hash['testsuite']['errors'].to_i
        #mhash['measure_failures'] = hash['testsuite']['failures'].to_i
        #mhash['measure_skipped'] = hash['testsuite']['skipped'].to_i

        #@measure_results[measure_name] = mhash

        #@total_errors += mhash['measure_errors']
        #@total_failures += mhash['measure_failures']
 
      end

      @error_status = true if @total_errors > 0

    end

    def to_file
      # save as a json and have something else parse it/plot it.

      @summary['test_directory'] = @path_to_results
      @summary['total_files'] = @total_files
      @summary['total_issues'] = @total_issues
      @summary['total_info'] = @total_info
      @summary['total_warnings'] = @total_warnings
      
      FileUtils.mkdir_p "#{@path_to_results}/" unless Dir.exist? "#{@path_to_results}/"
      File.open("#{@path_to_results}/rubocop.json", 'w') do |file|
        file << JSON.pretty_generate(@summary)
      
      end

    end
  end
end
