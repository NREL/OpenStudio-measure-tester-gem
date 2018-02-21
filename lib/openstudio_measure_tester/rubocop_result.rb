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
    attr_reader :file_info
    attr_reader :file_warnings
    attr_reader :file_errors
    attr_reader :summary

    def initialize(path_to_results)

      @path_to_results = path_to_results
      @error_status = false
      @tested_files = 0
      @total_issues = 0
      @total_errors = 0
      @total_warnings = 0
      @total_info = 0

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

        @summary = hash

        hash['checkstyle']['file'].each do |key,value|
            file = key['name']
            measure_name = file.split('/')[-1].split('.')[0].split('-')[1]
            files += file + "\n"

            if key['error']

              @file_issues = 0
              @file_info = 0
              @file_warnings = 0
              @file_errors = 0

              if key['error'].class == Array
                @file_issues = key['error'].length
                key['error'].each do |s|
                  if s['severity'] === "info"
                    @file_info += 1
                  elsif s['severity'] === "warning"
                    @file_warnings += 1
                  elsif s['severity'] === "error" #is this even correct?? 
                    @file_errors += 1
                  end
                end
              end

              if key['error'].class == Hash
                @file_issues = 1
                if key['error']['severity'] === "info"
                  @file_info += 1
                elsif key['error']['severity'] === "warning"
                  @file_warnings += 1
                elsif key['error']['severity'] === "error"
                  @file_errors += 1
                end

              end
              
              mhash = {}

              mhash['tested_class'] = measure_name
              mhash['measure_issues'] = @file_issues
              mhash['measure_info'] = @file_info
              mhash['measure_warnings'] = @file_warnings              
              mhash['measure_errors'] = @file_errors
              @measure_results[measure_name] = mhash

              @total_issues += @file_issues
              @total_info += @file_info
              @total_warnings += @file_warnings 
              @total_errors += @file_errors
            
            end

        end

      end

      puts "total files: #{total_files}"
      puts "total issues: #{@total_issues} (#{@total_info} info, #{@total_warnings} warnings, #{@total_errors} errors)"

      # TODO: still need to get errors ID'd
      @error_status = true if @total_errors > 0

    end

    def to_file
      # save as a json and have something else parse it/plot it.

      @summary['test_directory'] = @path_to_results
      @summary['total_files'] = @total_files
      @summary['total_issues'] = @total_issues
      @summary['total_info'] = @total_info
      @summary['total_warnings'] = @total_warnings
      @summary['total_errors'] = @total_errors
      
      FileUtils.mkdir_p "#{@path_to_results}/" unless Dir.exist? "#{@path_to_results}/"
      File.open("#{@path_to_results}/rubocop.json", 'w') do |file|
        file << JSON.pretty_generate(@summary)
      
      end

    end
  end
end
