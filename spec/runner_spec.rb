# frozen_string_literal: true

########################################################################################################################
#  OpenStudio(R), Copyright (c) 2008-2020, Alliance for Sustainable Energy, LLC. All rights reserved.
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

RSpec.describe OpenStudioMeasureTester::Runner do
  it 'should run openstudio style checks on single measure' do
    measure_dir = 'spec/test_measures/AddOverhangsByProjectionFactor'

    FileUtils.rm_rf "#{measure_dir}/test_results" if Dir.exist? "#{measure_dir}/test_results"
    expect(!Dir.exist?("#{measure_dir}/test_results"))

    runner = OpenStudioMeasureTester::Runner.new(measure_dir)

    # this measure does not pass
    expect(runner.run_style(false)).to eq 1

    # verify that the results live in the base_dir
    expect(!Dir.exist?("#{measure_dir}/test_results"))

    # verify that the results live in the base_dir
    expect(Dir.exist?("#{measure_dir}/test_results/openstudio_style/openstudio_style.json"))
    expect(Dir.exist?("#{measure_dir}/test_results/combined_results.json"))

    # verify that coverage and minitest results are not cluttering up current directory
    expect(!Dir.exist?("#{Dir.pwd}/coverage"))
    expect(!Dir.exist?("#{Dir.pwd}/minitest"))
  end

  it 'should run rubocop on single measure' do
    measure_dir = 'spec/test_measures/AddOverhangsByProjectionFactor'

    FileUtils.rm_rf "#{measure_dir}/test_results" if Dir.exist? "#{measure_dir}/test_results"
    expect(!Dir.exist?("#{measure_dir}/test_results"))

    runner = OpenStudioMeasureTester::Runner.new(measure_dir)

    # this measure does not pass
    expect(runner.run_rubocop(false)).to eq 1

    # verify that the results live in the base_dir
    expect(Dir.exist?("#{measure_dir}/test_results"))

    expect(Dir.exist?("#{measure_dir}/test_results/rubocop/rubocop.json"))
    expect(Dir.exist?("#{measure_dir}/test_results/combined_results.json"))

    # verify that coverage and minitest results are not cluttering up current directory
    expect(!Dir.exist?("#{Dir.pwd}/coverage"))
    expect(!Dir.exist?("#{Dir.pwd}/minitest"))
  end

  it 'should run minitest on single measure' do
    measure_dir = 'spec/test_measures/AddOverhangsByProjectionFactor'

    FileUtils.rm_rf "#{measure_dir}/test_results" if Dir.exist? "#{measure_dir}/test_results"
    expect(!Dir.exist?("#{measure_dir}/test_results"))

    runner = OpenStudioMeasureTester::Runner.new(measure_dir)

    # this measure does not pass
    expect(runner.run_test(false, Dir.pwd, false)).to eq 1

    # verify that the results live in the base_dir
    expect(Dir.exist?("#{measure_dir}/test_results"))

    expect(Dir.exist?("#{measure_dir}/test_results/reports/TEST-AddOverhangsByProjectionFactor-Test.xml"))
    expect(Dir.exist?("#{measure_dir}/test_results/combined_results.json"))

    # verify that coverage and minitest results are not cluttering up current directory
    expect(!Dir.exist?("#{Dir.pwd}/coverage"))
    expect(!Dir.exist?("#{Dir.pwd}/minitest"))
  end

  it 'should run all on single measure' do
    measure_dir = 'spec/test_measures/AddOverhangsByProjectionFactor'

    FileUtils.rm_rf "#{measure_dir}/test_results" if Dir.exist? "#{measure_dir}/test_results"
    expect(!Dir.exist?("#{measure_dir}/test_results"))

    runner = OpenStudioMeasureTester::Runner.new(measure_dir)

    # this measure does not pass
    expect(runner.run_all(Dir.pwd)).to eq 1

    # verify that the results live in the base_dir
    expect(Dir.exist?("#{measure_dir}/test_results"))

    expect(Dir.exist?("#{measure_dir}/test_results/reports/TEST-AddOverhangsByProjectionFactor-Test.xml"))
    expect(Dir.exist?("#{measure_dir}/test_results/combined_results.json"))

    # verify that coverage and minitest results are not cluttering up current directory
    expect(!Dir.exist?("#{Dir.pwd}/coverage"))
    expect(!Dir.exist?("#{Dir.pwd}/minitest"))
  end
end
