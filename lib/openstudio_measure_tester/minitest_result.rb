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

class MinitestResult
  attr_reader :error_status

  attr_reader :total_assertions
  attr_reader :total_errors
  attr_reader :total_failures
  attr_reader :total_skipped
  attr_reader :total_tests

  def initialize(path_to_results)
    @path_to_results = path_to_results
    @error_status = false
    @total_tests = 0
    @total_assertions = 0
    @total_errors = 0
    @total_failures = 0
    @total_skipped = 0

    parse_results
  end

  def parse_results
    puts @path_to_results

    Dir["#{@path_to_results}/reports/*.xml"].each do |file|
      puts "Parsing minitest report #{file}"
      hash = Hash.from_xml(File.read(file))

      # pp hash
      # "tests"=>"2",
      # "failures"=>"0",
      # "errors"=>"0",
      # "skipped"=>"0",
      # "assertions"=>"46",

      @total_assertions += hash["testsuite"]["assertions"].to_i
      @total_errors += hash["testsuite"]["errors"].to_i
      @total_failures += hash["testsuite"]["failures"].to_i
      @total_skipped += hash["testsuite"]["skipped"].to_i
      @total_tests += hash["testsuite"]["tests"].to_i
    end

    error_status = true if @total_errors > 0
  end
end