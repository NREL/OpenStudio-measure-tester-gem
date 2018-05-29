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
        desc 'new test task'
        task :test do
          runner = OpenStudioMeasureTester::Runner.new(Rake.application.original_dir)
          # Need to pass in the current directory because the results of minitest and coverage end up going into
          # the root directorys
          exit runner.run_test(Dir.pwd)
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
        task all: ['openstudio:rubocop', 'openstudio:style', 'openstudio:test'] do
          exit_status = post_process_results
          exit exit_status
        end

        # Hide the core tasks from being displayed when calling rake -T
        # Rake::Task['openstudio:test_core_command'].clear_comments
      end
    end
  end
end
