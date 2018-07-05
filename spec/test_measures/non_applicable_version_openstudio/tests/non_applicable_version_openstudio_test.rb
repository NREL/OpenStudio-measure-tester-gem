require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'fileutils'

require_relative '../measure.rb'
require 'minitest/autorun'


class NonApplicableVersionOpenStudioTest < Minitest::Test
  
  def test_min_version
     
    # create an instance of the measure
    measure = NonApplicableVersionOpenStudio.new
    
    # create an instance of a runner
    runner = OpenStudio::Ruleset::OSRunner.new
    
    # make an empty model
    model = OpenStudio::Model::Model.new
    
    assert(true)
  end
end


