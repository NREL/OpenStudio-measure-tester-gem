# frozen_string_literal: true

# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

class String
  def to_snakecase
    r = gsub(/::/, '/')
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .tr('-', '_')
        .downcase
    r.gsub!('energy_plus', 'energyplus')
    r.gsub!('open_studio', 'openstudio')
    r
  end

  def to_camelcase
    r = split('_').collect(&:capitalize).join
    r.gsub!('Energyplus', 'EnergyPlus')
    r.gsub!('Openstudio', 'OpenStudio')
    r
  end

  # simple method to create titles -- very custom to catch known inflections
  def titleize
    arr = ['a', 'an', 'the', 'by', 'to']
    upcase_arr = ['DX', 'EDA', 'AEDG', 'LPD', 'COP', 'GHLEP', 'ZEDG', 'QAQC', 'PV']
    r = tr('_', ' ').gsub(/\w+/) do |match|
      match_result = match
      if upcase_arr.include?(match.upcase)
        match_result = upcase_arr[upcase_arr.index(match.upcase)]
      elsif arr.include?(match)
        match_result = match
      else
        match_result = match.capitalize
      end
      match_result
    end

    # fix a couple known camelcase versions
    r.gsub!('Energyplus', 'EnergyPlus')
    r.gsub!('Openstudio', 'OpenStudio')
    r
  end
end

# Extend the Git log to add an empty method - for rubocop autocorrect happiness.
module Git
  class Log
    def empty?
      size.zero?
    end
  end
end
