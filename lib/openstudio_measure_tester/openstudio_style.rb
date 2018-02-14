########################################################################################################################
#  OpenStudio(R), Copyright (c) 2008-2018, Alliance for Sustainable Energy, LLC. All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
#  following conditions are met:
#
#  (1) Redistributions of source code must retain the above copyright notice, this list of conditions and the following
#  disclaimer.
#
#  (2) Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#  following disclaimer in the documentation and/or other materials provided with the distribution.
#
#  (3) Neither the name of the copyright holder nor the names of any contributors may be used to endorse or promote
#  products derived from this software without specific prior written permission from the respective party.
#
#  (4) Other than as required in clauses (1) and (2), distributions in any form of modifications or other derivative
#  works may not use the "OpenStudio" trademark, "OS", "os", or any other confusingly similar designation without
#  specific prior written permission from Alliance for Sustainable Energy, LLC.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
#  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER, THE UNITED STATES GOVERNMENT, OR ANY CONTRIBUTORS BE LIABLE FOR
#  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
#  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
########################################################################################################################

module OpenStudioMeasureTester
  class OpenStudioStyle
    CHECKS = [
        {
            regex: /OpenStudio::Ruleset::ModelUserScript/,
            check_type: :if_exists,
            message: 'OpenStudio::Ruleset::ModelUserScript is deprecated, use OpenStudio::Measure::ModelMeasure instead.',
            type: :deprecated,
            severity: :error
        }, {
            regex: /OpenStudio::Ruleset::OSRunner/,
            check_type: :if_exists,
            message: 'OpenStudio::Ruleset::OSRunner is deprecated, use OpenStudio::Measure::OSRunner instead.',
            type: :deprecated,
            severity: :error
        }, {
            regex: /OpenStudio::Ruleset::OSArgumentVector/,
            check_type: :if_exists,
            message: 'OpenStudio::Ruleset::OSArgumentVector is deprecated, use OpenStudio::Measure::OSArgumentVector instead.',
            type: :deprecated,
            severity: :error
        }, {
            regex: /OpenStudio::Ruleset::OSArgumentMap/,
            check_type: :if_exists,
            message: 'OpenStudio::Ruleset::OSArgumentMap is deprecated, use OpenStudio::Measure::OSArgumentMap instead.',
            type: :deprecated,
            severity: :error
        }, {
            regex: /def name(.*?)end/m,
            check_type: :if_missing,
            message: '\'def name\' is missing.',
            type: :syntax,
            severity: :error
        }, {
            regex: /def description(.*?)end/m,
            check_type: :if_missing,
            message: '\'def description\' is missing.',
            type: :syntax,
            severity: :error
        }, {
            regex: /def modeler_description(.*?)end/m,
            check_type: :if_missing,
            message: '\'def modeler_description\' is missing.',
            type: :syntax,
            severity: :error
        }
    ].freeze

    def initialize(measure_dir)
      @measure_dir = measure_dir
      @messages = []
      @measure_hash = {}

      # Load in the method infoExtractor which will load measure info (helpful comment huh?)
      # https://github.com/NREL/OpenStudio/blob/e7aa6be05a714814983d68ea840ca61383e9ef54/openstudiocore/src/measure/OSMeasureInfoGetter.cpp#L254
      eval(::OpenStudio::Measure.infoExtractorRubyFunction)

      measure = OpenStudio::BCLMeasure.load(measure_dir)
      if measure.empty?
        log_message(0, "Failed to load measure '#{measure_dir}'", :general, :error)
      else
        measure = measure.get
        measure_info = infoExtractor(measure, OpenStudio::Model::OptionalModel.new, OpenStudio::OptionalWorkspace.new)

        @measure_hash = measure_hash(@measure_dir, measure, measure_info)

        # Some more processing for validating the data
        @measure_hash[:name_underscore] = @measure_hash[:class_name].to_underscore
        @measure_hash[:name_titleized] = @measure_hash[:name].titleize

        # At this point, the measure.rb file is ensured to exist

        # run static checks
        run_regex_checks

        validate_measure_hash

        pp @measure_hash
      end
    end

    def log_message(line_number, message, type = :syntax, severity = :info)
      new_message = {
          line: line_number,
          message: message,
          type: type,
          severity: severity
      }
      @messages << new_message
    end

    def results
      @messages
    end

    def errors?
      !@messages.empty?
    end

    def save_results(filename)
      File.open(filename, 'w') do |file|
        file << JSON.pretty_generate(@results)
      end
    end

    def run_regex_checks
      filedata = File.read("#{@measure_dir}/measure.rb")
      CHECKS.each do |check|
        if check[:check_type] == :if_exists
          if filedata =~ check[:regex]
            log_message(0, check[:message], check[:type], check[:severity])
          end
        elsif check[:check_type] == :if_missing
          if filedata !~ check[:regex]
            log_message(0, check[:message], check[:type], check[:severity])
          end
        end
      end
    end

    # check the name of the measure and make sure that there are no unwanted characters
    #
    # @param String: name of the measure to parse
    def validate_name(name)
      errors = []

      clean_name = name
      units = nil

      # remove everything btw parentheses
      if clean_name =~ /\(.+?\)/
        log_message(0, "Display name '#{name}' appears to have units. Set units in the setUnits method.")
      end

      # remove characters
      if clean_name =~ /\?|\.|\#/
        log_message(0, "Display name '#{name}' cannot contain ?#.[] characters.", :syntax, :error)
      end
    end

    def parse_measure_xml
      h = Hash.from_xml(File.read(@filename_xml))

      # pull out some information
      @measure_hash[:name_xml] = h['measure']['name']
      @measure_hash[:uid] = h['measure']['uid']
      @measure_hash[:version_id] = h['measure']['version_id']
      if h['measure']['tags'].is_a? Hash
        @measure_hash[:tags] = h['measure']['tags']['tag']
      end
      pp @measure_hash

      @measure_hash[:modeler_description_xml] = h['measure']['modeler_description']
      @measure_hash[:description_xml] = h['measure']['description']
    end

    # Validate the measure hash to make sure that it is meets the style guide. This will also perform the selection
    # of which data to use for the "actual metadata"
    def validate_measure_hash
      validate_name(@measure_hash[:name])

      if @measure_hash[:name] != @measure_hash[:name_underscore]
        log_message("Measure name is not snake_case", :syntax, :error)
      end

      log_message('Could not find measure description in measure.', :structure, :warning) unless @measure_hash[:description]
      log_message('Could not find modeler description in measure.', :structure, :warning) unless @measure_hash[:modeler_description]
      log_message('Could not find display_name in measure.', :structure, :warning) unless @measure_hash[:display_name]
      log_message('Could not find measure name in measure.', :structure, :warning) unless @measure_hash[:name]

      @measure_hash[:arguments].each do |arg|
        validate_name(arg[:display_name])
        # {
        #     :name => "relative_building_rotation",
        #     :display_name =>
        #         "Number of Degrees to Rotate Building (positive value is clockwise).",
        #     :description => "",
        #     :type => "Double",
        #     :required => true,
        #     :model_dependent => false,
        #     :default_value => 90.0
        # }
      end
    end

    ###################################################################################################################
    # These methods are copied from the measure_manager.rb file in OpenStudio. Once the measure_manager.rb file
    # is shipped with OpenStudio, we can deprecate the copying over.
    #
    # https://github.com/NREL/OpenStudio/blob/7865ba413ef52e8c41b8b95d6643d68eb949f1c4/openstudiocore/src/cli/measure_manager.rb#L355
    ###################################################################################################################
    def measure_hash(measure_dir, measure, measure_info)
      result = {}
      result[:measure_dir] = measure_dir
      result[:name] = measure.name
      result[:directory] = measure.directory.to_s
      if measure.error.is_initialized
        result[:error] = measure.error.get
      end
      result[:uid] = measure.uid
      result[:uuid] = measure.uuid.to_s
      result[:version_id] = measure.versionId
      result[:version_uuid] = measure.versionUUID.to_s
      version_modified = measure.versionModified
      if version_modified.is_initialized
        result[:version_modified] = version_modified.get.toISO8601
      else
        result[:version_modified] = nil
      end
      result[:xml_checksum] = measure.xmlChecksum
      result[:name] = measure.name
      result[:display_name] = measure.displayName
      result[:class_name] = measure.className
      result[:description] = measure.description
      result[:modeler_description] = measure.modelerDescription
      result[:tags] = []
      measure.tags.each {|tag| result[:tags] << tag}

      result[:outputs] = []
      begin
        # this is an OS 2.0 only method
        measure.outputs.each do |output|
          out = {}
          out[:name] = output.name
          out[:display_name] = output.displayName
          out[:short_name] = output.shortName.get if output.shortName.is_initialized
          out[:description] = output.description
          out[:type] = output.type
          out[:units] = output.units.get if output.units.is_initialized
          out[:model_dependent] = output.modelDependent
          result[:outputs] << out
        end
      rescue StandardError
      end

      attributes = []
      measure.attributes.each do |a|
        value_type = a.valueType
        if value_type == 'Boolean'.to_AttributeValueType
          attributes << {name: a.name, display_name: a.displayName(true).get, value: a.valueAsBoolean}
        elsif value_type == 'Double'.to_AttributeValueType
          attributes << {name: a.name, display_name: a.displayName(true).get, value: a.valueAsDouble}
        elsif value_type == 'Integer'.to_AttributeValueType
          attributes << {name: a.name, display_name: a.displayName(true).get, value: a.valueAsInteger}
        elsif value_type == 'Unsigned'.to_AttributeValueType
          attributes << {name: a.name, display_name: a.displayName(true).get, value: a.valueAsUnsigned}
        elsif value_type == 'String'.to_AttributeValueType
          attributes << {name: a.name, display_name: a.displayName(true).get, value: a.valueAsString}
        end
      end
      result[:attributes] = attributes

      result[:arguments] = measure_info ? get_arguments_from_measure_info(measure_info) : []

      result
    end

    def get_arguments_from_measure_info(measure_info)
      result = []

      measure_info.arguments.each do |argument|
        type = argument.type

        arg = {}
        arg[:name] = argument.name
        arg[:display_name] = argument.displayName
        arg[:description] = argument.description.to_s
        arg[:type] = argument.type.valueName
        arg[:required] = argument.required
        arg[:model_dependent] = argument.modelDependent

        if type == 'Boolean'.to_OSArgumentType
          arg[:default_value] = argument.defaultValueAsBool if argument.hasDefaultValue

        elsif type == 'Double'.to_OSArgumentType
          arg[:units] = argument.units.get if argument.units.is_initialized
          arg[:default_value] = argument.defaultValueAsDouble if argument.hasDefaultValue

        elsif type == 'Quantity'.to_OSArgumentType
          arg[:units] = argument.units.get if argument.units.is_initialized
          arg[:default_value] = argument.defaultValueAsQuantity.value if argument.hasDefaultValue

        elsif type == 'Integer'.to_OSArgumentType
          arg[:units] = argument.units.get if argument.units.is_initialized
          arg[:default_value] = argument.defaultValueAsInteger if argument.hasDefaultValue

        elsif type == 'String'.to_OSArgumentType
          arg[:default_value] = argument.defaultValueAsString if argument.hasDefaultValue

        elsif type == 'Choice'.to_OSArgumentType
          arg[:default_value] = argument.defaultValueAsString if argument.hasDefaultValue
          arg[:choice_values] = []
          argument.choiceValues.each {|value| arg[:choice_values] << value}
          arg[:choice_display_names] = []
          argument.choiceValueDisplayNames.each {|value| arg[:choice_display_names] << value}

        elsif type == 'Path'.to_OSArgumentType
          arg[:default_value] = argument.defaultValueAsPath.to_s if argument.hasDefaultValue

        end

        result << arg
      end

      result
    end
  end
end
