module OpenStudioMeasureTester
  # The runner is the workhorse that executes the tests. This class does not invoke Rake and can be run
  # as a library method or as a CLI call
  class Runner

    # Initialize the runner
    #
    # @param base_dir [string] Base dir, measures will be recursively tested from this location. Results will be here too.
    def initialize(base_dir)
      @base_dir = base_dir

      puts "Base dir is #{base_dir}"
    end

    # Create and return the location where the tests results need to be stored
    def test_results_dir
      dir = "#{@base_dir}/test_results"
      FileUtils.mkdir_p dir unless Dir.exist? dir
      return dir
    end

    # Run ERB to create the dashboard
    def dashboard
      template = OpenStudioMeasureTester::Dashboard.new(test_results_dir)
      template.render
    end

    # Prepare the current directory and the root directory to remove old test results before running
    # the new tests
    #
    # @param base_dir [string] Base directory where results will be stored. If called from rake it is the location of the Rakefile.
    # @param current_dir [string] The current working directory. If called from Rake it is the active directory.
    def self.pre_process_minitest(base_dir, current_dir)
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
    def pre_process_rubocop
      # copy over the .rubocop.yml file into the root directory of where this is running.
      shared_rubocop_file = File.expand_path('../../.rubocop.yml', File.dirname(__FILE__))
      dest_file = "#{File.expand_path(@base_dir)}/.rubocop.yml"
      if shared_rubocop_file != dest_file
        FileUtils.copy(shared_rubocop_file, dest_file)
      end

      puts "Current directory is #{@base_dir}"
      # puts "Pre-processing tests run in #{@base_dir}"
      puts "Test results will be stored in: #{test_results_dir}"

      FileUtils.rm_rf "#{test_results_dir}/rubocop" if Dir.exist? "#{test_results_dir}/rubocop"
      FileUtils.rm_rf "#{@base_dir}/rubocop" if Dir.exist? "#{@base_dir}/rubocop"

      # Call the test_results dir to create the directory and return it as a string.
      return test_results_dir
    end

    # Post process the various results and save them into the base_dir
    #
    # @param measures_dir [string] The current working directory. If called from Rake it is the active directory.
    def post_process_results
      puts "Current directory: #{@base_dir}"
      puts "Test results will be stored in: #{test_results_dir}"

      results = OpenStudioMeasureTester::OpenStudioTestingResult.new(@base_dir, test_results_dir)
      results.save_results # one single file for dashboard

      # call the create dashboard command now that we have results
      dashboard

      # return the results exit code
      return results.exit_code
    end

    # OpenStudio style check preparation
    #
    # @param base_dir [string] Base directory where results will be stored. If called from rake it is the location of the Rakefile.
    # @param measures_dir [string] The current working directory. If called from Rake it is the active directory.
    def pre_process_style
      puts "Current directory is #{@base_dir}"
      puts "Test results will be stored in: #{test_results_dir}"

      FileUtils.rm_rf "#{test_results_dir}/openstudio_style" if Dir.exist? "#{test_results_dir}/openstudio_style"
      FileUtils.rm_rf "#{@base_dir}/openstudio_style" if Dir.exist? "#{@base_dir}/openstudio_style"

      # Call the test_results dir to create the directory and return it as a string.
      return test_results_dir
    end

    def run_style
      pre_process_style

      # Run the style tests
      style = OpenStudioMeasureTester::OpenStudioStyle.new(test_results_dir,"#{@base_dir}/**/measure.rb")
      style.save_results

      # postprocess the results
      return post_process_results
    end


    def run_rubocop(auto_correct=false)
      pre_process_rubocop

      rubocop_results_file = "#{test_results_dir}/rubocop/rubocop-results.xml"
      # The documentation on running RuboCop from the Ruby source is not really helpful. I reversed engineered this
      # by putting in puts statements to my locally install rubocop gem to see how options were passed.
      #
      # https://github.com/bbatsov/rubocop/blob/9bdbaba9dcaa3dedad5e857b440d0d8988b806f5/lib/rubocop/runner.rb#L25
      require 'rubocop/formatter/checkstyle_formatter'
      options = {
          # out and output_path do not actually save the results, has to be appended after the formatter.
          # out: 'junk.xml',
          # output_path: 'junk.xml',
          auto_correct: auto_correct,
          color: false,
          formatters: ['simple', ['RuboCop::Formatter::CheckstyleFormatter', rubocop_results_file]]
      }

      # Load in the ruby config from the root directory
      config_store = RuboCop::ConfigStore.new
      # puts "Searching for .rubocop.yml recursively from #{@base_dir}"
      config_store.for(@base_dir)

      rc_runner = RuboCop::Runner.new(options, config_store)
      rc_runner.run(["#{File.expand_path(@base_dir)}/**/*.rb"])

      # postprocess the results
      return post_process_results
    end

    def run_test
      puts "trying to run the unit tests"



    end

    # at_exit do
    #   if $!.success?
    #     puts self
    #     puts "what teh hell, why not"
    #   else
    #     puts "there was an error"
    #   end
    #
    # end
  end
end

# Module.new do
#   at_exit do
#     if $!.nil?
#       puts "Ran successfully... now what?"
#       exit 0
#     else
#       puts "There was an error running OpenStudio Measure Tester"
#     end
#   end
# end

