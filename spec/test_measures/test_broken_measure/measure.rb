# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class TestBrokenMeasure < OpenStudio::Ruleset::ModelUserScript
  # human readable name
  def name
    return 'Test Broken Measure'
  end

  # human readable description
  def description
    return 'This Measure intentionally has invalid ruby code inside the arguments method.  It should be used for testing how Measure Manager handles this scenario.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'This Measure intentionally has invalid ruby code inside the arguments method.  It should be used for testing how Measure Manager handles this scenario.'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Ruleset::OSArgumentVector.new

    # This is intentionally invalid ruby
    some_var = THIS_CONSTANT_INTENTIONALLY_NOT_DEFINED_FOR_TESTING_MEASURE_MANAGER

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    return true
  end
end

# register the measure to be used by the application
TestBrokenMeasure.new.registerWithApplication
