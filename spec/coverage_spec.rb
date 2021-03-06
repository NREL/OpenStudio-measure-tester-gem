# frozen_string_literal: true

########################################################################################################################
#  OpenStudio(R), Copyright (c) 2008-2021, Alliance for Sustainable Energy, LLC. All rights reserved.
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

RSpec.describe OpenStudioMeasureTester::Coverage do
  it 'should parse results' do
    dir = 'spec/files/coverage'
    c = OpenStudioMeasureTester::Coverage.new(dir)
    c.parse_results

    expect(c.total_percent_coverage).to eq 87.54
    expect(c.measure_coverages.size).to eq 7
  end

  it 'should return a hash of results' do
    dir = 'spec/files/coverage'
    c = OpenStudioMeasureTester::Coverage.new(dir)
    c.parse_results
    res = c.to_hash

    expect(res).to be_instance_of(Hash)
    expect(res.key?('by_measure')).to eq true
    expect(res.key?('total_percent_coverage')).to eq true
  end

  it 'should save a json file' do
    dir = 'spec/files/coverage'
    c = OpenStudioMeasureTester::Coverage.new(dir)
    c.parse_results
    res = c.save_results
    filename = "#{dir}/coverage.json"
    expect(File.exist?(filename)).to be true
  end

  it 'should find class names' do
    c = OpenStudioMeasureTester::Coverage.new('spec/files/coverage')
    class_name = c.parse_class_name(File.expand_path('spec/test_measures/AddOverhangsByProjectionFactor/measure.rb'))
    expect(class_name).to eq 'AddOverhangsByProjectionFactor'

    # check when the leading path is not on the system
    c = OpenStudioMeasureTester::Coverage.new('spec/files/coverage')
    class_name = c.parse_class_name(File.expand_path('/a/b/c/d/spec/test_measures/AddOverhangsByProjectionFactor/measure.rb'))
    expect(class_name).to eq 'AddOverhangsByProjectionFactor'
  end
end
