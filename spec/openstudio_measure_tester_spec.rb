# frozen_string_literal: true

# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

RSpec.describe OpenStudioMeasureTester do
  before :all do
    OpenStudioMeasureTester::RakeTask.new
  end

  it 'has a version number' do
    expect(OpenStudioMeasureTester::VERSION).not_to be nil
  end

  it 'should have new rake tasks' do
    expect(Rake::Task.task_defined?('openstudio:test')).to be true
    expect(Rake::Task.task_defined?('openstudio:rubocop')).to be true
  end

  it 'should load openstudio' do
    require 'openstudio'
    puts "OpenStudio Loaded. Version: #{OpenStudio.openStudioLongVersion}"
  rescue LoadError
    puts 'Could not load OpenStudio'
    expect(false).to eq true
  end

  context 'Measure tests in non-root directory' do
    before :each do
      @curdir = Dir.pwd
      Dir.chdir('spec/test_measures/')
    end

    after :each do
      Dir.chdir(@curdir)
    end

    it 'should run measure tests' do
      require 'openstudio'
      puts "OpenStudio Loaded. Version: #{OpenStudio.openStudioLongVersion}"

      IO.popen('rake openstudio:test') do |io|
        while (line = io.gets)
          puts line
        end
      end
      expect(File.exist?('test_results/minitest/html_reports/index.html')).to eq true
      expect(File.exist?('test_results/minitest/reports/TEST-SetGasBurnerEfficiency-Test.xml')).to eq true
      expect(File.exist?('test_results/minitest/reports/TEST-RotateBuilding-Test.xml')).to eq true
    end

    it 'should run rubocop' do
      IO.popen('rake openstudio:rubocop') do |io|
        while (line = io.gets)
          puts line
        end
      end
      expect(File.exist?('test_results/rubocop/rubocop-results.xml')).to eq true
    end

    it 'should run openstudio style' do
      IO.popen('rake openstudio:style') do |io|
        while (line = io.gets)
          puts line
        end
      end
      expect(File.exist?('test_results/openstudio_style/openstudio_style.json')).to eq true
    end
  end
end
