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

require 'openstudio'

require 'pp'
require 'git'
require 'rexml/document'
require 'minitest'
require 'simplecov'

# override the default at_exit call
SimpleCov.at_exit do
end

# Override the minitest autorun, to, well, not autorun
def Minitest.autorun; end

# Rubocop loads a lot of objects, anyway to minimize would be nice.
require 'rubocop'

require_relative 'openstudio_measure_tester/core_ext'
require_relative 'openstudio_measure_tester/version'
require_relative 'openstudio_measure_tester/openstudio_style'
require_relative 'openstudio_measure_tester/minitest_result'
require_relative 'openstudio_measure_tester/coverage'
require_relative 'openstudio_measure_tester/rubocop_result'
require_relative 'openstudio_measure_tester/openstudio_testing_result'
require_relative 'openstudio_measure_tester/dashboard'
require_relative 'openstudio_measure_tester/runner'

require_relative 'openstudio_measure_tester/rake_task'

# Set the encoding to UTF-8. OpenStudio Docker images do not have this set by default
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

module OpenStudioMeasureTester
  # No action here. Most of this will be rake_tasks at the moment.
end

class Minitest::Test
  def teardown
    before = ObjectSpace.count_objects
    GC.start
    after = ObjectSpace.count_objects
    delta = {}
    before.each { |k, v| delta[k] = v - after[k] if after.key? k }
    puts "GC Delta: #{delta}"
  end
end
