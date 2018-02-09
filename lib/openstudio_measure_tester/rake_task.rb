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

module OpenStudioMeasureTester
  class RakeTask < Rake::TaskLib
    attr_accessor :name

    def initialize(*args, &task_block)
      @name = args.shift || :openstudio

      # desc 'Run OpenStudio Measure Tests'
        # task(name, *args) do |_, task_args|
      #   RakeFileUtils.send(:verbose, verbose) do
      #     if task_block
      #       task_block.call(*[self, task_args].slice(0, task_block.arity))
      #     end
      #
      #     # Do nothing yet
      #   end
      # end

      # Subtasks under the @name (default: openstudio) name
      setup_subtasks(name)
    end

    private

    def setup_subtasks(name)
      namespace name do
        Rake::TestTask.new(:test) do |task|
          task.description = 'Run measures tests recursively from current directory'
          task.pattern = ["#{Rake.application.original_dir}/**/*_test.rb"]
          task.verbose = true
        end

        # The .rubocop.yml file downloads the rubocop rules from the OpenStudio-resources repo.
        # This may cause an issue if the Gem directory does not have write access.
        RuboCop::RakeTask.new do |task|
          task.options = ['--no-color', '--out=rubocop-results.xml', '--format=simple']
          task.formatters = ['RuboCop::Formatter::CheckstyleFormatter']
          task.requires = ['rubocop/formatter/checkstyle_formatter']
          # Run the rake at the original root directory
          task.patterns = ["#{Rake.application.original_dir}/**/*.rb"]
          # don't abort rake on failure
          task.fail_on_error = false
        end
      end
    end
  end
end
