#start the measure
class NonApplicableVersionOpenStudio < OpenStudio::Measure::ModelMeasure

  #define the name that a user will see
  def name
    return "Non Applicable Version OpenStudio"
  end

  def arguments(model)
    return OpenStudio::Measure::OSArgumentVector.new
  end 

  #define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    #use the built-in error checking
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    return true

  end #end the run method


end #end the measure

#this allows the measure to be used by the application
NonApplicableVersionOpenStudio.new.registerWithApplication
