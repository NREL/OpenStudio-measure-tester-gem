# frozen_string_literal: true

# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

RSpec.describe OpenStudioMeasureTester::RubocopResult do
  it 'should parse results' do
    dir = 'spec/files/rubocop'
    mr = OpenStudioMeasureTester::RubocopResult.new(dir)

    expect(mr.error_status).to eq true
    expect(mr.total_files).to eq 18
    expect(mr.total_issues).to eq 479
    expect(mr.total_errors).to eq 423
    expect(mr.total_measures).to eq 8
  end

  it 'should write the json file' do
    dir = 'spec/files/rubocop'
    write_file = "#{dir}/rubocop.json"
    File.delete(write_file) if File.exist? write_file

    mr = OpenStudioMeasureTester::RubocopResult.new(dir)
    expect(File.exist?(write_file)).to be true
  end

  it 'should not double count measures with a common substring' do
    dir = 'spec/files/rubocop/common_substring'
    mr = OpenStudioMeasureTester::RubocopResult.new(dir)

    expect(mr.error_status).to eq true
    expect(mr.total_files).to eq 2
    expect(mr.total_measures).to eq 2
    expect(mr.total_info).to eq 0
    expect(mr.total_warnings).to eq 0
    expect(mr.total_errors).to eq 1
    expect(mr.total_issues).to eq 1
  end
end
