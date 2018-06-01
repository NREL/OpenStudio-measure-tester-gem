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

    attr_reader :file_issues
    attr_reader :file_info
    attr_reader :file_warnings
    attr_reader :file_errors

    attr_reader :total_measures
    attr_reader :total_files

    attr_reader :total_issues
    attr_reader :total_info
    attr_reader :total_warnings
    attr_reader :total_errors

    attr_reader :summary
    attr_reader :by_measure

    def initialize(path_to_results)
      @path_to_results = path_to_results
      @error_status = false
      @total_files = 0
      @total_issues = 0
      @total_errors = 0
      @total_warnings = 0
      @total_info = 0
      @total_measures = 0

      @summary = {}

      @by_measure = {}

      parse_results
      to_file
    end

    def parse_results
      Dir["#{@path_to_results}/rubocop-results.xml"].each do |file|
        puts "Parsing Rubocop report #{file}"

        measure_names = []

        @total_files = 0
        doc = REXML::Document.new(File.open(file)).root

        # Go through the XML and find all the measure names first
        doc.elements.each('file') do |rc_file|
          @total_files += 1
          measure_name = rc_file.attributes['name']
          if measure_name
            parts = measure_name.split('/')
            if parts.last == 'measure.rb'
              measure_names << parts[-2]
            end
          end
        end

        @total_measures = measure_names.length

        # now go find the specific data about the measure
        measure_names.each do |measure_name|
          mhash = {}
          mhash['measure_issues'] = 0
          mhash['measure_info'] = 0
          mhash['measure_warnings'] = 0
          mhash['measure_errors'] = 0
          mhash['files'] = []

          cn = ''
          doc.elements.each('file') do |rc_file|
            next unless rc_file.attributes['name'].include? measure_name

            # Save off the file information
            fhash = {}
            fhash['file_name'] = rc_file.attributes['name'].split('/')[-1]
            fhash['violations'] = []

            # get the class name out of the measure file! wow, okay... sure why not.
            if fhash['file_name'] == 'measure.rb'
              File.readlines(rc_file.attributes['name']).each do |line|
                if (line.include? 'class') && line.split(' ')[0] == 'class'
                  cn = line.split(' ')[1].gsub /_?[tT]est\z/, ''
                  break
                end
              end
            end

            @file_issues = 0
            @file_info = 0
            @file_warnings = 0
            @file_errors = 0

            violations = []
            rc_file.elements.each('error') do |rc_error|
              @file_issues += 1
              if rc_error.attributes['severity'] == 'info'
                @file_info += 1
              elsif rc_error.attributes['severity'] == 'warning'
                @file_warnings += 1
              elsif rc_error.attributes['severity'] == 'error'
                @file_errors += 1
              end
              violations << {
                  line: rc_error.attributes['line'],
                  column: rc_error.attributes['column'],
                  severity: rc_error.attributes['severity'],
                  message: rc_error.attributes['message']
              }
            end
            fhash['issues'] = @file_issues
            fhash['info'] = @file_info
            fhash['warning'] = @file_warnings
            fhash['error'] = @file_errors
            fhash['violations'] = violations

            mhash['measure_issues'] += @file_issues
            mhash['measure_info'] += @file_info
            mhash['measure_warnings'] += @file_warnings
            mhash['measure_errors'] += @file_errors

            @total_issues += @file_issues
            @total_info += @file_info
            @total_warnings += @file_warnings
            @total_errors += @file_errors

            mhash['files'] << fhash
          end
          @by_measure[cn] = mhash
        end
      end

      puts "Total files: #{total_files}"
      puts "Total issues: #{@total_issues} (#{@total_info} info, #{@total_warnings} warnings, #{@total_errors} errors)"

      @error_status = true if @total_errors > 0
    end

    def to_hash
      results = {}
      results['total_measures'] = @total_measures
      results['total_files'] = @total_files
      results['total_issues'] = @total_issues
      results['total_info'] = @total_info
      results['total_warnings'] = @total_warnings
      results['total_errors'] = @total_errors
      results['by_measure'] = @by_measure

      results
    end

    def to_file
      # save as a json and have something else parse it/plot it.
      res_hash = to_hash
      @summary = res_hash
      FileUtils.mkdir_p "#{@path_to_results}/" unless Dir.exist? "#{@path_to_results}/"
      File.open("#{@path_to_results}/rubocop.json", 'w') do |file|
        file << JSON.pretty_generate(res_hash)
      end
    end
  end
end
