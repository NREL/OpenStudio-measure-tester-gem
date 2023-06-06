# frozen_string_literal: true

# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

module OpenStudioMeasureTester
  class OpenStudioTestingResult
    attr_reader :results

    # Pass in the results_dir where all the results are stored
    # @param results_dir [String]: Directory where the results are scattered. Typically the root dir or where rake was executed
    # @param test_results_dir [String]: Where the final results are to be stored
    # @param orig_results_dir [String]: Optional directory where results are sometimes thrown into that need to be moved (coverage and minitest)
    def initialize(results_dir, test_results_dir, orig_results_dir = nil)
      @results_dir = results_dir
      @test_results_dir = test_results_dir
      @orig_results_dir = orig_results_dir
      @results = {}

      puts "results_dir is #{@results_dir}"
      puts "test_results_dir is #{@test_results_dir}"
      puts "orig_results_dir is #{@orig_results_dir}"

      # get the repository info
      repo_name = 'unknown'
      current_branch = 'unknown'
      sha = 'unknown'
      begin
        g = Git.open(Dir.pwd)
        config = g.config
        repo_name = config['remote.origin.url'] ? config['remote.origin.url'].split('/').last.chomp('.git') : nil
        current_branch = g.branch.name || nil
        logs = g.log
        sha = nil
        if !logs.empty?
          sha = logs.first.sha
        end
      rescue StandardError => e
        puts 'Could not find .git for measure(s), will not be able to report git information'
      end

      # check if the results data already exist, and if so, then load the file now to keep the results
      load_results

      # add/overwrite repo info in results
      @results['repo_name'] = repo_name
      @results['current_branch'] = current_branch
      @results['sha'] = sha

      aggregate_results
    end

    def aggregate_results
      # openstudio style is stored in the correct location (the test_results directory)
      # OpenStudio Style will have already run, so just grab the results out of the directory and jam into
      # the @results hash
      filename = "#{@test_results_dir}/openstudio_style/openstudio_style.json"
      if File.exist? filename
        puts 'Found OpenStudio Style results, parsing'
        @results['openstudio_style'] = JSON.parse(File.read(filename))
      end

      filename = "#{@test_results_dir}/rubocop/rubocop.json"
      if File.exist? filename
        @results['rubocop'] = JSON.parse(File.read(filename))
      elsif Dir.exist? "#{@test_results_dir}/rubocop"
        # Parse the rubocop results if they were not cached
        rc = OpenStudioMeasureTester::RubocopResult.new("#{@test_results_dir}/rubocop")
        @results['rubocop'] = rc.summary
      end

      # don't copy if the directories are the same
      if @test_results_dir != @orig_results_dir
        # coverage
        if Dir.exist? "#{@orig_results_dir}/coverage"
          puts 'Found Coverage results, parsing'
          FileUtils.rm_rf "#{@test_results_dir}/coverage" if Dir.exist? "#{@test_results_dir}/coverage"
          FileUtils.cp_r "#{@orig_results_dir}/coverage/.", "#{@test_results_dir}/coverage"
          FileUtils.rm_rf "#{@orig_results_dir}/coverage" if Dir.exist? "#{@orig_results_dir}/coverage"

          cov = OpenStudioMeasureTester::Coverage.new("#{@test_results_dir}/coverage")
          cov.parse_results
          @results['coverage'] = cov.to_hash
        end

        # minitest
        if Dir.exist?("#{@orig_results_dir}/test/html_reports") || Dir.exist?("#{@orig_results_dir}/test/reports")
          puts 'Found Minitest Results, parsing'
          # Do not delete the compatibilty directory which is generated when the test is run
          FileUtils.rm_rf "#{@test_results_dir}/minitest/html_reports" if Dir.exist? "#{@test_results_dir}/minitest/html_reports"
          FileUtils.rm_rf "#{@test_results_dir}/minitest/reports" if Dir.exist? "#{@test_results_dir}/minitest/reports"

          FileUtils.mkdir_p "#{@test_results_dir}/minitest"

          # Copy the files over in case the folder is locked.
          if Dir.exist?("#{@orig_results_dir}/test/html_reports")
            puts 'Moving Minitest HTML results to results directory'
            FileUtils.cp_r "#{@orig_results_dir}/test/html_reports/.", "#{@test_results_dir}/minitest/html_reports"
          end

          if Dir.exist?("#{@orig_results_dir}/test/reports")
            puts 'Moving Minitest XML results to results directory'
            FileUtils.cp_r "#{@orig_results_dir}/test/reports/.", "#{@test_results_dir}/minitest/reports"
          end

          # Delete the test folder if it is empty
          FileUtils.rm_rf "#{@orig_results_dir}/test" if Dir.exist?("#{@orig_results_dir}/test") && Dir.entries("#{@orig_results_dir}/test").size == 2

          # Load in the data into the minitest object
          mr = OpenStudioMeasureTester::MinitestResult.new("#{@test_results_dir}/minitest")
          @results['minitest'] = mr.summary
        end
      end
    end

    def load_results
      filename = "#{@test_results_dir}/combined_results.json"
      begin
        @results = JSON.parse(File.read(filename)) if File.exist? filename
      rescue StandardError
        @results = {}
      end
    end

    def save_results
      File.open("#{@test_results_dir}/combined_results.json", 'w') do |file|
        file << JSON.pretty_generate(@results)
      end
    end

    # Return the exit code based on some arbitrary limit across all the tests
    def exit_code
      # there must be no unit test failures
      # pp @results
      final_exit_code = 0
      if @results['rubocop']
        # more than 10 errors per file on average
        status = @results['rubocop']['total_errors'] / @results['rubocop']['total_files']
        if status > 10
          puts "More than 10 RuboCop errors per file found. Found #{status}"
          final_exit_code = 1
        end
      end

      if @results['openstudio_style']
        total_files = @results['openstudio_style']['by_measure'].count
        status = @results['openstudio_style']['total_errors'] / total_files
        if status > 10
          puts "More than 10 OpenStudio Style errors found per file. Found #{status}"
          final_exit_code = 1
        end

        status = @results['openstudio_style']['total_warnings'] / total_files
        if status > 25
          puts "More than 25 OpenStudio Style warnings found per file, reporting as error. Found #{status}"
          final_exit_code = 1
        end
      end

      if @results['minitest']
        if @results['minitest'][:total_errors] > 0 || @results['minitest'][:total_failures] > 0
          puts 'Unit Test (Minitest) errors/failures found.'
          final_exit_code = 1
        end
      end

      # if @results['coverage']
      #   status = @results['coverage']['total_percent_coverage']
      #   if status < 70
      #     puts "Code coverage is less than 70%, raising error. Coverage was #{status}"
      #     final_exit_code = 1
      #   end
      # end

      # Since the data are relative to the directory from which it has been run, then just show from current dir (.)
      puts 'Open ./test_results/dashboard/index.html to view measure testing dashboard.'

      return final_exit_code
    end
  end
end
