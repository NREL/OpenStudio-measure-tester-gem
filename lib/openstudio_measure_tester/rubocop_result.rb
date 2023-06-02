# frozen_string_literal: true

# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

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
      Dir[File.join(@path_to_results, 'rubocop-results.xml')].each do |file|
        puts "Parsing Rubocop report #{file}"

        measure_names = []

        @total_files = 0
        doc = REXML::Document.new(File.open(file)).root

        puts "Finished reading #{file}"

        # Go through the XML and find all the measure names first
        doc.elements.each('//checkstyle/file') do |rc_file|
          @total_files += 1
          measure_name = rc_file.attributes['name']
          if measure_name
            # If the user runs the tests from within the directory (where the measure.rb) file exists, then the
            # measure name is not included in the XML. Therefore, the measure_name will need to be abstracted by
            # the name of the directory relative to where the test_results are.
            if measure_name.include? File::SEPARATOR
              parts = measure_name.split(File::SEPARATOR)
              if parts.last == 'measure.rb'
                measure_names << parts[-2]
              end
            elsif measure_name == 'measure.rb'
              # the measure name must be extracted from the directory
              parts = file.split(File::SEPARATOR)
              measure_names << parts[-4]
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
          doc.elements.each('//checkstyle/file') do |rc_file|
            # Allow processing when the file is just the measure.rb
            if rc_file.attributes['name'] != 'measure.rb'
              if !rc_file.attributes['name'].include? measure_name
                next
              end
            end

            # Save off the file information
            fhash = {}
            if rc_file.attributes['name'].include? File::SEPARATOR
              fhash['file_name'] = rc_file.attributes['name'].split(File::SEPARATOR)[-1]
            else
              fhash['file_name'] = rc_file.attributes['name']
            end
            fhash['violations'] = []

            # get the class name out of the measure file! wow, okay... sure why not.
            if fhash['file_name'] == 'measure.rb'
              if File.exist? rc_file.attributes['name']
                File.readlines(rc_file.attributes['name']).each do |line|
                  if (line.include? 'class') && line.split(' ')[0] == 'class'
                    cn = line.split(' ')[1].gsub /_?[tT]est\z/, ''
                    break
                  end
                end
              else
                puts "Could not find measure to parse for extracting class name in Rubocop. PWD: #{Dir.pwd} filename: #{rc_file.attributes['name']}"
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

      puts "Total files: #{@total_files}"
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
