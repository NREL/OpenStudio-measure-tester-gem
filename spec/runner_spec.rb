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

  it 'should list all measures no matter the base dir' do
    expected_number_of_measures = Pathname.new('spec/test_measures').children.select(&:directory?).size

    puts Dir.pwd
    runner = OpenStudioMeasureTester::Runner.new('spec')
    expect(runner.all_measure_dirs.size).to eq expected_number_of_measures

    runner = OpenStudioMeasureTester::Runner.new('spec/test_measures')
    expect(runner.all_measure_dirs.size).to eq expected_number_of_measures

    Dir.chdir("spec/test_measures") do
      runner = OpenStudioMeasureTester::Runner.new('.')
      expect(runner.all_measure_dirs.size).to eq expected_number_of_measures
    end
  end

  it 'should locate the git repo root regardless of the current pwd' do
    expected = Pathname.new(__dir__).parent
    runner = OpenStudioMeasureTester::Runner.new(Dir.pwd)
    expect(runner.locate_git_dir).not_to be_nil
    expect(runner.locate_git_dir).to eq expected

    runner = OpenStudioMeasureTester::Runner.new('spec/test_measures')
    expect(runner.locate_git_dir).not_to be_nil
    expect(runner.locate_git_dir).to eq expected

    Dir.chdir("spec/test_measures") do
      runner = OpenStudioMeasureTester::Runner.new('.')
      expect(runner.locate_git_dir).not_to be_nil
      expect(runner.locate_git_dir).to eq expected
    end
  end

  context "cleans up tempfile in existing measure" do
    let(:new_file_in_existing_measure) { Pathname.new(__dir__) / 'test_measures/AddOverhangsByProjectionFactor/tempfile' }
    after {
      File.delete(new_file_in_existing_measure)
    }

    it 'should detect changed files' do
      runner = OpenStudioMeasureTester::Runner.new('spec/test_measures')
      ori = runner.get_git_changed_files
      File.write(new_file_in_existing_measure, 'hello')
      new = runner.get_git_changed_files
      expect(new.size).to eq (ori.size + 1)
      diff = new - ori
      expect(diff.size).to eq 1
      expect(diff.first).to eq new_file_in_existing_measure.relative_path_from(Pathname.new(Dir.pwd))
    end
  end

  context "cleans up temp measure test" do

    let(:new_measure_dir)  { Pathname.new(__dir__) / 'test_measures/temp_measure' }

    after {
      FileUtils.rm_rf(new_measure_dir)
    }

    it 'should list changed measures only' do
      runner = OpenStudioMeasureTester::Runner.new('spec/test_measures')
      ori = runner.changed_measure_dirs

      FileUtils.mkdir_p(new_measure_dir)
      FileUtils.touch(new_measure_dir / 'measure.py')
      new = runner.changed_measure_dirs

      expect(new.size).to eq (ori.size + 1)
      diff = new - ori
      expect(diff.size).to eq 1
      expect(diff.first).to eq new_measure_dir.relative_path_from(Pathname.new(Dir.pwd))
    end
  end
end
