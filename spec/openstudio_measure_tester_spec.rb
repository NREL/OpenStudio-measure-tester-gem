RSpec.describe OpenStudioMeasureTester do
  it 'has a version number' do
    expect(OpenStudioMeasureTester::VERSION).not_to be nil
  end

  it 'should have new rake tasks' do
    OpenStudioMeasureTester::RakeTask.new

    expect(Rake::Task.task_defined?('openstudio:test')).to be true
    expect(Rake::Task.task_defined?('openstudio:rubocop')).to be true
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
    end

    after :each do
      Dir.chdir(@curdir)
    end

    it 'should run measure tests' do
      require 'openstudio'
      puts "OpenStudio Loaded. Version: #{OpenStudio.openStudioLongVersion}"

      Dir.chdir('spec/test_measures/')
      Rake.application['openstudio:test'].invoke

      puts "Contents: #{Dir.entries('test')}"
      puts "Contents: #{Dir.entries('test/html_reports')}"
      expect(File.exist?('test/html_reports/index.html')).to eq true
      expect(File.exist?('test/reports/TEST-SetGasBurnerEfficiency-Test.xml')).to eq true
    end

    it 'should run rubocop' do
      Dir.chdir('spec/test_measures/')
      Rake.application['openstudio:rubocop'].invoke
      expect(File.exist?('rubocop-results.xml')).to eq true
    end
  end
end
