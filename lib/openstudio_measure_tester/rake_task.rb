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

    def setup_subtasks(name)
      namespace name do
        ####################################### Minitest and Coverage #######################################
        task :prepare_minitest do
          OpenStudioMeasureTester::Runner.pre_process_minitest(Rake.application.original_dir, Dir.pwd)
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

        desc 'Run OpenStudio Measure Unit Tests'
        task test: ['openstudio:prepare_minitest', 'openstudio:test_core'] do
          runner = OpenStudioMeasureTester::Runner.new(Rake.application.original_dir)
          exit runner.post_process_results
        end


        ####################################### RuboCop #######################################
        # Need to create a namespace so that we can have openstudio:rubocop and openstudio:rubocop:auto_correct.
        namespace :rubocop do
          task :check do
            # original_dir is the location where Rakefile exists, Dir.pwd is where the rake task was called.
            runner = OpenStudioMeasureTester::Runner.new(Rake.application.original_dir)

            exit runner.run_rubocop
          end

          desc 'Run RuboCop Auto Correct on Measures'
          task :auto_correct do
            # original_dir is the location where Rakefile exists, Dir.pwd is where the rake task was called.
            runner = OpenStudioMeasureTester::Runner.new(Rake.application.original_dir, Dir.pwd)

            exit runner.run_rubocop(true)
          end
        end

        desc 'Run RuboCop on Measures'
        task rubocop: 'openstudio:rubocop:check'

        ####################################### Style #######################################
        desc 'Run OpenStudio Style Checks'
        task :style do
          runner = OpenStudioMeasureTester::Runner.new(Rake.application.original_dir)
          exit runner.run_style
        end

        ####################################### Post Processing and Dashboarding #######################################
        desc 'Post process results into one directory'
        task :post_process do
          runner = OpenStudioMeasureTester::Runner.new(Rake.application.original_dir)
          exit runner.post_process_results
        end

        desc 'Generate dashboard'
        task :dashboard do
          dashboard(Rake.application.original_dir)
        end

        desc 'Run MiniTest, Coverage, RuboCop, and Style on measures, then dashboard results'
        task all: ['openstudio:prepare_minitest', 'openstudio:test_core', 'openstudio:style_core'] do
          exit_status = post_process_results(Rake.application.original_dir, Dir.pwd)
          exit exit_status
        end

        # Hide the core tasks from being displayed when calling rake -T
        Rake::Task['openstudio:test_core_command'].clear_comments
      end
    end
  end
end
