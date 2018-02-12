RSpec.describe OpenStudioMeasureTester do
  it 'has a version number' do
    expect(OpenStudioMeasureTester::VERSION).not_to be nil
  end

  it 'should have new rake tasks' do
    OpenStudioMeasureTester::RakeTask.new

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

      Dir.chdir(@curdir)
      expect(File.exist?('test_results/minitest/html_reports/index.html')).to eq true
      expect(File.exist?('test_results/minitest/reports/TEST-SetGasBurnerEfficiency-Test.xml')).to eq true
      expect(File.exist?('test_results/minitest/reports/TEST-RotateBuilding-Test.xml')).to eq true
    end

    it 'should run rubocop' do
      Rake.application['openstudio:rubocop'].invoke
      # expect($?.success?).to eq false
      Dir.chdir(@curdir)
      expect(File.exist?('test_results/rubocop/rubocop-results.xml')).to eq true
    end
  end
end
