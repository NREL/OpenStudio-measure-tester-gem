# frozen_string_literal: true

# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

RSpec.describe OpenStudioMeasureTester::MinitestResult do
  it 'should parse results' do
    dir = 'spec/files/minitest'
    mr = OpenStudioMeasureTester::MinitestResult.new(dir)

    expect(mr.total_assertions).to eq 144
    expect(mr.total_errors).to eq 1
    expect(mr.total_failures).to eq 1
    expect(mr.total_skipped).to eq 1
    expect(mr.total_tests).to eq 21
    expect(mr.total_compatibility_errors).to eq 1
    expect(mr.error_status).to eq true

    expect(mr.measure_results.size).to eq 8
  end
end
