RSpec.describe OpenStudioMeasureTester do
  before :all do
    OpenStudioMeasureTester::RakeTask.new
  end

  it 'has a version number' do
    expect(OpenStudioMeasureTester::VERSION).not_to be nil
  end

  it 'should have new rake tasks' do
    expect(Rake::Task.task_defined?('openstudio:test')).to be true
    expect(Rake::Task.task_defined?('openstudio:rubocop_core')).to be true
  end

  it 'should load openstudio' do
    begin
      require 'openstudio'
      puts "OpenStudio Loaded. Version: #{OpenStudio.openStudioLongVersion}"
    rescue LoadError
      puts 'Could not load OpenStudio'
      expect(false).to eq true
    end
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

      Rake.application['openstudio:test'].invoke
      Rake.application['openstudio:test'].reenable

      Dir.chdir(@curdir)
      expect(File.exist?('test_results/minitest/html_reports/index.html')).to eq true
      expect(File.exist?('test_results/minitest/reports/TEST-SetGasBurnerEfficiency-Test.xml')).to eq true
      expect(File.exist?('test_results/minitest/reports/TEST-RotateBuilding-Test.xml')).to eq true
    end

    it 'should run rubocop' do
      Rake.application['openstudio:rubocop'].invoke
      Rake.application['openstudio:rubocop'].reenable
      # expect($?.success?).to eq false
      Dir.chdir(@curdir)
      expect(File.exist?('test_results/rubocop/rubocop-results.xml')).to eq true
    end

    it 'should run openstudio style' do
      # this doesn't seem to be running. not sure why at the moment.
      puts 'running openstudio style'
      Rake.application['openstudio:style'].invoke
      Rake.application['openstudio:style'].reenable
      # expect($?.success?).to eq false
      Dir.chdir(@curdir)
      expect(File.exist?('test_results/openstudio_style/pristine.json')).to eq true
    end
  end
end
