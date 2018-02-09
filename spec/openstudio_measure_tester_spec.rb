RSpec.describe OpenStudioMeasureTester do
  it "has a version number" do
    expect(OpenStudioMeasureTester::VERSION).not_to be nil
  end

  it "should run measure tests" do
    require 'openstudio'
    curdir = Dir.pwd
    begin
      Dir.chdir('spec/test_measures/')

      # call rake
      system('rake openstudio:test')
    ensure
      Dir.chdir(curdir)
    end
  end
end
