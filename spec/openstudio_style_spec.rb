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

RSpec.describe OpenStudioMeasureTester::OpenStudioStyle do
  it 'should not find measure in unknown path' do
    measure_path = 'spec/test_measures/RotateBuildingDNE/*'
    style = OpenStudioMeasureTester::OpenStudioStyle.new("#{measure_path}/test_results", measure_path)

    expect(style.results[:by_measure].empty?).to eq true
  end

  it 'should parse an OpenStudio Measure' do
    measure_path = 'spec/test_measures/RotateBuilding/*'
    style = OpenStudioMeasureTester::OpenStudioStyle.new("#{measure_path}/test_results", measure_path)

    # make sure that the infoExtractor method loads correctly (from OpenStudio)
    expect(style.respond_to?(:infoExtractor)).to eq true
    expect(style.results[:by_measure][:RotateBuilding][:measure_errors]).to eq 10
    expect(style.results[:by_measure][:RotateBuilding][:measure_warnings]).to eq 3
    expect(style.results[:by_measure][:RotateBuilding][:measure_info]).to eq 1
    expect(style.results[:by_measure][:RotateBuilding][:issues].size).to eq 14
  end

  it 'should check for naming conventions' do
    measure_path = 'spec/test_measures/ModelMeasure'
    style = OpenStudioMeasureTester::OpenStudioStyle.new("#{measure_path}/test_results", measure_path)

    style.measure_messages.clear
    style.validate_name('Name', 'period.in.names.are.bad')
    expect(style.measure_messages.last[:message]).to eq "Name 'period.in.names.are.bad' cannot contain ?#.[] characters."

    style.measure_messages.clear
    style.validate_name('Name', 'snake_case_is_right', :warning, ensure_snakecase: true)
    style.validate_name('Name', 'CamelCaseIsUpAndDown', :warning, ensure_camelcase: true)
    style.validate_name('Name', 'MixedUp_And_case', :warning, ensure_camelcase: true)
    style.validate_name('Name', 'MixedUp_And_case', :warning, ensure_snakecase: true)
    expect(style.measure_messages.first[:message]).to eq "Name 'MixedUp_And_case' is not CamelCase."
    expect(style.measure_messages.last[:message]).to eq "Name 'MixedUp_And_case' is not snake_case."
    style.measure_messages.clear

    style.validate_name('Name', 'trailing_spaces ', :warning, ensure_snakecase: true)
    style.validate_name('Name', ' trailing_spaces', :warning, ensure_snakecase: true)
    expect(style.measure_messages.first[:message]).to eq "Name 'trailing_spaces ' has leading or trailing spaces."
    expect(style.measure_messages.last[:message]).to eq "Name ' trailing_spaces' has leading or trailing spaces."
    style.measure_messages.clear

    style.validate_name('Name', 'Square Footage (ft2)')
    expect(style.measure_messages.first[:message]).to eq "Name 'Square Footage (ft2)' appears to have units. Set units in the setUnits method."

    outfile = "#{measure_path}/test_results/openstudio_style/openstudio_style.json"
    File.delete(outfile) if File.exist? outfile
    style.save_results
    expect(File.exist?(outfile)).to eq true
  end
end
