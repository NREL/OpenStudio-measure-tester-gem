# frozen_string_literal: true

# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

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
