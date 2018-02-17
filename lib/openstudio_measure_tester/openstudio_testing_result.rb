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
  class OpenStudioTestingResult
    attr_reader :results

    # Pass in the results_dir where all the results are stored
    # @param results_dir [String]: Directory where the results are scattered. Typically the root dir or where rake was executed
    # @param test_results_dir [String]: Where the final results are to be stored
    def initialize(results_dir, test_results_dir)
      @results_dir = results_dir
      @test_results_dir = test_results_dir
      @results = {}

      # get the repository info
      g = Git.open(Dir.pwd)
      config = g.config
      repo_name = config['remote.origin.url'].split('/')[1].split('.')[0]
      current_branch = g.branch.name
      @results['repo_name'] = repo_name
      @results['current_branch'] = current_branch
      # TODO add failsafe

      # check if the results data already exist, and if so, then load the file now to keep the results
      load_results
      aggregate_results
    end

    def aggregate_results
      # TODO: check if we need this check of directories
      if @test_results_dir != @results_dir
        # coverage
        if Dir.exist? "#{@results_dir}/coverage"
          FileUtils.rm_rf "#{@test_results_dir}/coverage" if Dir.exist? "#{@test_results_dir}/coverage"
          FileUtils.mv "#{@results_dir}/coverage", "#{@test_results_dir}/."

          cov = OpenStudioMeasureTester::Coverage.new("#{@test_results_dir}/coverage")
          @results["coverage"] = cov.to_hash
        end

        # minitest
        if Dir.exist? "#{@results_dir}/test"
          FileUtils.rm_rf "#{@test_results_dir}/minitest" if Dir.exist? "#{@test_results_dir}/minitest"
          FileUtils.mv "#{@results_dir}/test", "#{@test_results_dir}/minitest"

          # Load in the data into the minitest object
          mr = OpenStudioMeasureTester::MinitestResult.new("#{@test_results_dir}/minitest")
          @results['minitest'] = mr.summary
        end

        # rubocop
        if Dir.exist? "#{@results_dir}/rubocop"
          FileUtils.rm_rf "#{@test_results_dir}/rubocop" if Dir.exist? "#{@test_results_dir}/rubocop"
          FileUtils.mv "#{@results_dir}/rubocop", "#{@test_results_dir}/rubocop"

          # need to create parser here!
          # trying!!! &^&%##%@((@*&()))!!
          rc = OpenStudioMeasureTester::RubocopResult.new("#{@test_results_dir}/rubocop")
          #@results['rubocop'] = rc.summary

        end

        # openstudio style
        if Dir.exist? "#{@results_dir}/openstudio_style"
          FileUtils.rm_rf "#{@test_results_dir}/openstudio_style" if Dir.exist? "#{@test_results_dir}/openstudio_style"
          FileUtils.mv "#{@results_dir}/openstudio_style", "#{@test_results_dir}/openstudio_style"

          # OpenStudio Style will have already run, so just grab the results out of the directory and jam into
          # the @results hash
          filename = "#{@test_results_dir}/openstudio_style/openstudio_style.json"
          if File.exist? filename
            @results['openstudio_style'] = JSON.parse(File.read(filename))
          end
        end
      end
    end

    def load_results
      filename = "#{@test_results_dir}/combined_results.json"
      begin
        @results = JSON.parse(File.read(filename)) if File.exist? filename
      rescue
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
      # TODO: fill this out
      return 0
    end
  end
end

