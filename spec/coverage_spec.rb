# frozen_string_literal: true

# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

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
