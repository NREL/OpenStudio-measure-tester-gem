# frozen_string_literal: true

# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

RSpec.describe 'CoreExt' do
  it 'should snakecase energyplus and openstudio correctly' do
    expect('EnergyPlusTestCase'.to_snakecase).to eq 'energyplus_test_case'
    expect('OpenStudioTestCase'.to_snakecase).to eq 'openstudio_test_case'
    expect('openstudio_test_case'.to_camelcase).to eq 'OpenStudioTestCase'
    expect('open_studio_test_case'.to_camelcase).to eq 'OpenStudioTestCase'
    expect('openstudio_test_case'.titleize).to eq 'OpenStudio Test Case'
  end
end
