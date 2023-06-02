# frozen_string_literal: true

# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

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
          exit runner.run_test(false, Dir.pwd, false)
        end

        ####################################### RuboCop #######################################
        # Need to create a namespace so that we can have openstudio:rubocop and openstudio:rubocop:auto_correct.
        namespace :rubocop do
          task :check do
            # original_dir is the location where Rakefile exists, Dir.pwd is where the rake task was called.
            runner = OpenStudioMeasureTester::Runner.new(Rake.application.original_dir)

            exit runner.run_rubocop(false)
          end

          desc 'Run RuboCop Auto Correct on Measures'
          task :auto_correct do
            # original_dir is the location where Rakefile exists, Dir.pwd is where the rake task was called.
            runner = OpenStudioMeasureTester::Runner.new(Rake.application.original_dir)

            exit runner.run_rubocop(false, true)
          end
        end

        desc 'Run RuboCop on Measures'
        task rubocop: 'openstudio:rubocop:check'

        ####################################### Style #######################################
        desc 'Run OpenStudio Style Checks'
        task :style do
          runner = OpenStudioMeasureTester::Runner.new(Rake.application.original_dir)
          exit runner.run_style(false)
        end

        ####################################### Post Processing and Dashboarding #######################################
        desc 'Post process results into one directory'
        task :post_process do
          runner = OpenStudioMeasureTester::Runner.new(Rake.application.original_dir)
          exit runner.post_process_results(Dir.pwd)
        end

        desc 'Generate dashboard'
        task :dashboard do
          runner = OpenStudioMeasureTester::Runner.new(Rake.application.original_dir)
          runner.dashboard
        end

        desc 'Run MiniTest, Coverage, RuboCop, and Style on measures, then dashboard results'
        task :all do
          runner = OpenStudioMeasureTester::Runner.new(Rake.application.original_dir)
          exit runner.run_all(Dir.pwd)
        end

        # Hide the core tasks from being displayed when calling rake -T
        # Rake::Task['openstudio:test_core_command'].clear_comments
      end
    end
  end
end
