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
        message: 'OpenStudio::Ruleset::ModelUserScript is deprecated, use OpenStudio::Measure::ModelMeasure instead.',
        type: :deprecation,
        severity: :error
        # "OSRunner is deprecated, use OpenStudio::Measure::OSRunner instead.",
        # "OSArgumentVector is deprecated, use OpenStudio::Measure::OSArgumentVector instead.",
        # "OSArgumentMap is deprecated, use OpenStudio::Measure::OSArgumentMap instead.",
      }
    ].freeze

    def initialize(filename)
      @filename = filename
      @filename_xml = "#{File.join(File.dirname(@filename), File.basename(@filename, '.*'))}.xml"
      @messages = []
      @measure_hash = {}

      if File.exist? @filename
        parse_measure_file
      else
        add_message(0, 'Measure ruby file does not exist', :general, :error)
      end

      # parse the XML
      if File.exist? @filename_xml
        parse_measure_xml
      else
        add_message(0, 'Measure XML file does not exist', :general, :error)
      end

      # validate the parsed data
      validate_measure_hash
    end

    def add_message(line_number, message, type = :syntax, severity = :info)
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

    def parse_measure_file
      # read in the measure file and extract some information
      measure_string = File.read(@filename)

      @measure_hash[:classname] = measure_string.match(/class (.*) </)[1]
      @measure_hash[:name] = @measure_hash[:classname].to_underscore
      @measure_hash[:display_name] = nil
      @measure_hash[:display_name_titleized] = @measure_hash[:name].titleize
      @measure_hash[:display_name_from_measure] = nil

      if measure_string =~ /OpenStudio::Ruleset::WorkspaceUserScript/
        @measure_hash[:measure_type] = 'EnergyPlusMeasure'
      elsif measure_string =~ /OpenStudio::Ruleset::ModelUserScript/
        @measure_hash[:measure_type] = 'RubyMeasure'
      elsif measure_string =~ /OpenStudio::Ruleset::ReportingUserScript/
        @measure_hash[:measure_type] = 'ReportingMeasure'
      elsif measure_string =~ /OpenStudio::Ruleset::UtilityUserScript/
        @measure_hash[:measure_type] = 'UtilityUserScript'
      else
        add_message(0, "measure type is unknown with an inherited class in #{@filename}: #{@measure_hash.inspect}", :general, :error)
        return
      end

      # New versions of measures have name, description, and modeler description methods
      n = measure_string.scan(/def name(.*?)end/m).first
      if n
        n = n.first.strip
        n.gsub!('return', '')
        n.gsub!(/"|'/, '')
        n.strip!
        @measure_hash[:display_name_from_measure] = n
      end

      # New versions of measures have name, description, and modeler description methods
      n = measure_string.scan(/def description(.*?)end/m).first
      if n
        n = n.first.strip
        n.gsub!('return', '')
        n.gsub!(/"|'/, '')
        n.strip!
        @measure_hash[:description] = n
      end

      # New versions of measures have name, description, and modeler description methods
      n = measure_string.scan(/def modeler_description(.*?)end/m).first
      if n
        n = n.first.strip
        n.gsub!('return', '')
        n.gsub!(/"|'/, '')
        n.strip!
        @measure_hash[:modeler_description] = n
      end

      @measure_hash[:arguments] = []

      args = measure_string.scan(/(.*).*=.*OpenStudio::(Ruleset|Measure)::OSArgument.*make(.*)Argument\((.*).*\)/)
      args.each do |arg|
        new_arg = {}
        new_arg[:name] = nil
        new_arg[:display_name] = nil
        new_arg[:variable_type] = nil
        new_arg[:local_variable] = nil
        new_arg[:units] = nil
        new_arg[:units_in_name] = nil

        new_arg[:local_variable] = arg[0].strip
        new_arg[:variable_type] = arg[1]
        arg_params = arg[2].split(',')
        new_arg[:name] = arg_params[0].gsub(/"|'/, '')
        next if new_arg[:name] == 'info_widget'
        choice_vector = arg_params[1] ? arg_params[1].strip : nil

        # try find the display name of the argument
        reg = /#{new_arg[:local_variable]}.setDisplayName\((.*)\)/
        if measure_string =~ reg
          new_arg[:display_name] = measure_string.match(reg)[1]
          new_arg[:display_name].gsub!(/"|'/, '') if new_arg[:display_name]
        else
          new_arg[:display_name] = new_arg[:name]
        end

        p = parse_measure_name(new_arg[:display_name])
        new_arg[:display_name] = p[0]
        new_arg[:units_in_name] = p[1]

        # try to get the units
        reg = /#{new_arg[:local_variable]}.setUnits\((.*)\)/
        if measure_string =~ reg
          new_arg[:units] = measure_string.match(reg)[1]
          new_arg[:units].gsub!(/"|'/, '') if new_arg[:units]
        end

        if measure_string =~ /#{new_arg[:local_variable]}.setDefaultValue/
          new_arg[:default_value] = measure_string.match(/#{new_arg[:local_variable]}.setDefaultValue\((.*)\)/)[1]
        else
          puts "[WARNING] #{@measure_hash[:name]}:#{new_arg[:name]} has no default value... will continue"
        end

        case new_arg[:variable_type]
          when 'Choice'
            # Choices to appear to only be strings?
            # puts "Choice vector appears to be #{choice_vector}"
            new_arg[:default_value].gsub!(/"|'/, '') if new_arg[:default_value]

            # parse the choices from the measure
            # scan from where the "instance has been created to the measure"
            possible_choices = nil
            possible_choice_block = measure_string # .scan(/#{choice_vector}.*=(.*)#{new_arg[:local_variable]}.*=/mi)
            if possible_choice_block
              # puts "possible_choice_block is #{possible_choice_block}"
              possible_choices = possible_choice_block.scan(/#{choice_vector}.*<<.*(')(.*)(')/)
              possible_choices += possible_choice_block.scan(/#{choice_vector}.*<<.*(")(.*)(")/)
            end

            # puts "Possible choices are #{possible_choices}"

            if possible_choices.nil? || possible_choices.empty?
              new_arg[:choices] = []
            else
              new_arg[:choices] = possible_choices.map { |c| c[1] }
            end

            # if the choices are inherited from the model, then need to just display the default value which
            # somehow magically works because that is the display name
            if new_arg[:default_value]
              new_arg[:choices] << new_arg[:default_value] unless new_arg[:choices].include?(new_arg[:default_value])
            end
          when 'String', 'Path'
            new_arg[:default_value].gsub!(/"|'/, '') if new_arg[:default_value]
          when 'Bool'
            if new_arg[:default_value]
              new_arg[:default_value] = new_arg[:default_value].casecmp('true').zero? ? true : false
            end
          when 'Integer'
            new_arg[:default_value] = new_arg[:default_value].to_i if new_arg[:default_value]
          when 'Double'
            new_arg[:default_value] = new_arg[:default_value].to_f if new_arg[:default_value]
          else
            raise "unknown variable type of #{new_arg[:variable_type]}"
        end

        @measure_hash[:arguments] << new_arg
      end
    end

    # check the name of the measure and make sure that there are no unwanted characters
    #
    # @param String: name of the measure to parse
    def parse_measure_name(name)
      errors = []

      clean_name = name
      units = nil

      # remove everything btw parentheses
      m = clean_name.match(/\((.+?)\)/)
      unless m.nil?
        errors << 'removing parentheses'
        units = m[1]
        clean_name = clean_name.gsub(/\((.+?)\)/, '')
      end

      # remove everything btw brackets
      m = clean_name.match(/\[(.+?)\]/)
      unless m.nil?
        errors << 'removing brackets,'
        clean_name = clean_name.gsub(/\[(.+?)\]/, '')
      end

      # remove characters
      m = clean_name.match(/(\?|\.|\#).+?/)
      unless m.nil?
        errors << 'removing any of following: ?.#'
        clean_name = clean_name.gsub(/(\?|\.|\#).+?/, '')
      end
      clean_name = clean_name.delete('.')
      clean_name = clean_name.delete('?')

      add_message(errors, :syntax, :error) unless errors.empty?
      [clean_name.strip, units]
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
      if @measure_hash.key? :name_xml
        if @measure_hash[:name_xml] != @measure_hash[:name]
          add_message(
            "Snake-cased name and the name in the XML do not match. Will default to automatic snake-cased measure name. #{@measure_hash[:name_xml]} <> #{@measure_hash[:name]}",
            :syntax,
            :error
          )
        end
      end

      add_message('Could not find measure description in measure.', :structure, :warning) unless @measure_hash[:description]
      add_message('Could not find modeler description in measure.', :structure, :warning) unless @measure_hash[:modeler_description]
      add_message('Could not find measure name in measure.', :structure, :warning) unless @measure_hash[:name_from_measure]

      # check the naming conventions
      if @measure_hash[:display_name_from_measure]
        if @measure_hash[:display_name_from_measure] != @measure_hash[:display_name_titleized]
          add_message('Display name from measure and automated naming do not match. Will default to the automated name until all measures use the name method because of potential conflicts due to bad copy/pasting.', :syntax, :warning)
        end
      end
      @measure_hash[:display_name] = @measure_hash.delete :display_name_titleized
      @measure_hash.delete :display_name_from_measure

      if @measure_hash.key?(:description) && @measure_hash.key?(:description_xml)
        if @measure_hash[:description] != @measure_hash[:description_xml]
          add_message('Measure description and XML description differ.', :syntax, :warning)
        end
        @measure_hash.delete(:description_xml)
      end

      if @measure_hash.key?(:modeler_description) && @measure_hash.key?(:modeler_description_xml)
        if @measure_hash[:modeler_description] != @measure_hash[:modeler_description_xml]
          add_message('Measure modeler description and XML modeler description differ.', :syntax, :warning)
        end
        @measure_hash.delete(:modeler_description_xml)
      end

      @measure_hash[:arguments].each do |arg|
        if arg[:units_in_name]
          add_message("It appears that units are embedded in the argument name for #{arg[:name]}.", :syntax, :error)
          if arg[:units]
            if arg[:units] != arg[:units_in_name]
              add_message('Units in argument name do not match units in setUnits method. Using setUnits.', :syntax, :error)
              arg.delete :units_in_name
            end
          else
            add_message('Units appear to be in measure name. Use setUnits.', :syntax, :error)
            arg[:units] = arg.delete :units_in_name
          end
        else
          # make sure to delete if null
          arg.delete :units_in_name
        end
      end
    end
  end
end
