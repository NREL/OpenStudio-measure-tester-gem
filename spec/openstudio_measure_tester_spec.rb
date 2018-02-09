RSpec.describe OpenStudioMeasureTester do
  it "has a version number" do
    expect(OpenStudioMeasureTester::VERSION).not_to be nil
  end

  it "should have new rake tasks" do
    OpenStudioMeasureTester::RakeTask.new

    expect(Rake::Task.task_defined?('openstudio:test')).to be true
    expect(Rake::Task.task_defined?('openstudio:rubocop')).to be true
  end

  context "Measure tests" do
    before :each do
      @curdir = Dir.pwd
    end

    after :each do
      Dir.chdir(@curdir)
    end

    it "should run measure tests" do
      require 'openstudio'

      Dir.chdir('spec/test_measures/')

      Rake.application['openstudio:test'].invoke

      expect('test/html_reports/index.html').to be_an_existing_file
      expect('test/reports/TEST-SetGasBurnerEfficiency-Test.xml').to be_an_existing_file
    end

    it "should run rubocop" do
      Rake.application['openstudio:rubocop'].invoke

      expect('test/html_reports/index.html').to be_an_existing_file
      expect('test/reports/TEST-SetGasBurnerEfficiency-Test.xml').to be_an_existing_file
    end
  end

end
