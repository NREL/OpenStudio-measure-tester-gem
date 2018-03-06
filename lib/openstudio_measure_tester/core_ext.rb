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
      size.zero? # rubocop:disable Style/ZeroLengthPredicate
    end
  end
end
