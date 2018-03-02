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

require 'rake'
require 'rake/tasklib'
require 'rake/testtask'
require 'rubocop/rake_task'

require_relative '../openstudio_measure_tester'

module OpenStudioMeasureTester
  class RakeTask < Rake::TaskLib
    attr_accessor :name

    def initialize(*args, &task_block)
      @name = args.shift || :openstudio

      setup_subtasks(@name)
    end

    private

    # Prepare the current directory and the root directory to remove old test results before running
    # the new tests
    def pre_process_minitest(base_dir)
      current_dir = Dir.pwd
      test_results_dir = "#{base_dir}/test_results"

      puts "Current directory is #{current_dir}"
      puts "Pre-processing tests run in #{base_dir}"
      puts "Test results will be stored in: #{test_results_dir}"

      FileUtils.rm_rf "#{test_results_dir}/coverage" if Dir.exist? "#{test_results_dir}/coverage"
      FileUtils.rm_rf "#{test_results_dir}/test/html_reports" if Dir.exist? "#{test_results_dir}/test/html_reports"
      FileUtils.rm_rf "#{test_results_dir}/test/reports" if Dir.exist? "#{test_results_dir}/test/reports"
      # remove the test directory if it is empty (size == 2 for . and ..)
      if Dir.exist?("#{test_results_dir}/test") && Dir.entries("#{test_results_dir}/test").size == 2
        FileUtils.rm_rf "#{test_results_dir}/test"
      end
      FileUtils.rm_rf "#{test_results_dir}/minitest" if Dir.exist? "#{test_results_dir}/minitest"
      FileUtils.rm_rf "#{base_dir}/coverage" if Dir.exist? "#{base_dir}/coverage"
      FileUtils.rm_rf "#{base_dir}/test" if Dir.exist? "#{base_dir}/test"
      FileUtils.rm_rf "#{base_dir}/minitest" if Dir.exist? "#{base_dir}/minitest"
      FileUtils.rm_rf "#{current_dir}/coverage" if Dir.exist? "#{current_dir}/coverage"
      FileUtils.rm_rf "#{current_dir}/test" if Dir.exist? "#{current_dir}/test"
      FileUtils.rm_rf "#{current_dir}/minitest" if Dir.exist? "#{current_dir}/minitest"

      # Create the test_results directory to store all the results
      FileUtils.mkdir_p "#{base_dir}/test_results"
    end

    # Rubocop stores the results (for now) in the test_results directory
    def pre_process_rubocop(base_dir)
      current_dir = Dir.pwd
      test_results_dir = "#{base_dir}/test_results"

      puts "Current directory is #{current_dir}"
      puts "Pre-processing tests run in #{base_dir}"
      puts "Test results will be stored in: #{test_results_dir}"

      FileUtils.rm_rf "#{test_results_dir}/rubocop" if Dir.exist? "#{test_results_dir}/rubocop"
      FileUtils.rm_rf "#{base_dir}/rubocop" if Dir.exist? "#{base_dir}/rubocop"
      FileUtils.rm_rf "#{current_dir}/rubocop" if Dir.exist? "#{current_dir}/rubocop"

      # Create the test_results directory to store all the results
      FileUtils.mkdir_p "#{base_dir}/test_results"
    end

    # OpenStudio style check preparation
    def pre_process_style(base_dir)
      current_dir = Dir.pwd
      test_results_dir = "#{base_dir}/test_results"

      puts "Current directory is #{current_dir}"
      puts "Pre-processing tests run in #{base_dir}"
      puts "Test results will be stored in: #{test_results_dir}"

      FileUtils.rm_rf "#{test_results_dir}/openstudio_style" if Dir.exist? "#{test_results_dir}/openstudio_style"
      FileUtils.rm_rf "#{base_dir}/openstudio_style" if Dir.exist? "#{base_dir}/openstudio_style"
      FileUtils.rm_rf "#{current_dir}/openstudio_style" if Dir.exist? "#{current_dir}/openstudio_style"

      # Create the test_results directory to store all the results
      FileUtils.mkdir_p "#{base_dir}/test_results"
    end

    def run_style(base_dir)
      style = OpenStudioMeasureTester::OpenStudioStyle.new("#{base_dir}/**/measure.rb")
      style.save_results
    end

    # Post process the various results and save them into the base_dir
    def post_process_results(base_dir)
      current_dir = Dir.pwd
      test_results_dir = "#{base_dir}/test_results"

      puts "Current directory: #{current_dir}"
      puts "Post-processing tests run in: #{base_dir}"
      puts "Test results will be stored in: #{test_results_dir}"

      FileUtils.mkdir_p test_results_dir

      results = OpenStudioMeasureTester::OpenStudioTestingResult.new(current_dir, test_results_dir)
      results.save_results # one single file for dashboard

      # call the create dashboard command now that we have results
      dashboard(base_dir)

      # return the results exit code
      return results.exit_code
    end

    # Run ERB to create the dashboard
    def dashboard(base_dir)
      template = OpenStudioMeasureTester::Dashboard.new(base_dir)
      template.render
    end

    def setup_subtasks(name)
      namespace name do
        task :prepare_minitest do
          pre_process_minitest(Rake.application.original_dir)
        end

        task :prepare_rubocop do
          # copy over the .rubocop.yml file
          shared_rubocop_file = File.expand_path('../../.rubocop.yml', File.dirname(__FILE__))
          dest_file = "#{Dir.pwd}/.rubocop.yml"
          if shared_rubocop_file != dest_file
            FileUtils.copy(shared_rubocop_file, dest_file)
          end
          pre_process_rubocop(Rake.application.original_dir)
        end

        task :prepare_style do
          pre_process_style(Rake.application.original_dir)
        end

        task style_core: [] do
          run_style(Rake.application.original_dir)
        end

        task :post_process_core do
          post_process_results(Rake.application.original_dir)
        end

        Rake::TestTask.new(:test_core_command) do |task|
          task.options = '--ci-reporter'
          task.description = 'Run measures tests recursively from current directory'
          task.pattern = [
            "#{Rake.application.original_dir}/**/*_test.rb",
            "#{Rake.application.original_dir}/**/*_Test.rb"
          ]
          task.verbose = true
        end

        task :test_core do
          begin
            Rake.application['openstudio:test_core_command'].invoke
          rescue StandardError
            puts 'Test failures in openstudio:test. Will continue to post-processing.'
          ensure
            Rake.application['openstudio:test_core_command'].reenable
          end
        end

        # The .rubocop.yml file downloads the RuboCop rules from the OpenStudio-resources repo.
        # This may cause an issue if the Gem directory does not have write access.
        RuboCop::RakeTask.new(:rubocop_core) do |task|
          task.options = ['--no-color', '--out=rubocop/rubocop-results.xml', '--format=simple']
          task.formatters = ['RuboCop::Formatter::CheckstyleFormatter']
          task.requires = ['rubocop/formatter/checkstyle_formatter']
          # Run the rake at the original root directory
          task.patterns = ["#{Rake.application.original_dir}/**/*.rb"]
          # don't abort rake on failure
          task.fail_on_error = false
        end

        desc 'Run OpenStudio Measure Unit Tests'
        task test: ['openstudio:prepare_minitest', 'openstudio:test_core'] do
          exit_status = post_process_results(Rake.application.original_dir)
          exit exit_status
        end

        # Need to create a namespace so that we can have openstudio:rubocop and openstudio:rubocop:auto_correct.
        namespace :rubocop do
          task check: ['openstudio:prepare_rubocop', 'openstudio:rubocop_core'] do
            exit_status = post_process_results(Rake.application.original_dir)
            exit exit_status
          end

          desc 'Run RuboCop Auto Correct on Measures'
          task auto_correct: 'openstudio:rubocop_core:auto_correct'
        end

        desc 'Run RuboCop on Measures'
        task rubocop: 'openstudio:rubocop:check'

        desc 'Run OpenStudio Style Checks'
        task style: ['openstudio:prepare_style', 'openstudio:style_core'] do
          exit_status = post_process_results(Rake.application.original_dir)
          exit exit_status
        end

        desc 'Post process results into one directory'
        task :post_process do
          exit_status = post_process_results(Rake.application.original_dir)
          exit exit_status
        end

        desc 'Generate dashboard'
        task :dashboard do
          dashboard(Rake.application.original_dir)
        end

        desc 'Run MiniTest, Coverage, RuboCop, and Style on measures, then dashboard results'
        task all: ['openstudio:prepare_minitest',
                   'openstudio:test_core',
                   'openstudio:prepare_rubocop',
                   'openstudio:rubocop_core',
                   'openstudio:prepare_style',
                   'openstudio:style_core'] do
          exit_status = post_process_results(Rake.application.original_dir)
          exit exit_status
        end

        # Hide the core tasks from being displayed when calling rake -T
        Rake::Task['openstudio:rubocop_core'].clear_comments
        Rake::Task['openstudio:test_core_command'].clear_comments
        Rake::Task['openstudio:rubocop_core:auto_correct'].clear_comments
      end
    end
  end
end
