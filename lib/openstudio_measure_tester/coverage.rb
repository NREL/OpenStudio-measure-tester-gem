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
  class Coverage
    attr_reader :total_percent_coverage
    attr_reader :total_lines
    attr_reader :total_relevant_lines
    attr_reader :covered_lines
    attr_reader :missed_lines
    attr_reader :avg_hits_per_line
    attr_reader :measure_coverages

    def initialize(path_to_results)
      @path_to_results = path_to_results
      @total_percent_coverage = 0
      @total_lines = 0
      @total_relevant_lines = 0
      @total_covered_lines = 0
      @total_missed_lines = 0

      @measure_coverages = {}

      parse_results

    end

    def parse_results
      file = "#{@path_to_results}/.resultset.json"

      puts 'Parsing coverage results'
      jsonData = File.read(file)
      hash = JSON.parse(jsonData);

      #pp hash

      hash['RSpec']['coverage'].each do |key, data|
        pp key
        # just do measure.rb for now
        parts = key.split('/')
        if parts.last == 'measure.rb'
          name = parts[-2]
          pp name

          mhash = {}
          mhash['name'] = name
          mhash['total_lines'] = data.size
          @total_lines += data.size
          # remove nils from array
          data.delete(nil)

          cov = data.count {|x| x > 0}
          mhash['percent_coverage'] = ((cov.to_f / data.size.to_f) * 100).round(2)
          mhash['missed_lines'] = data.size - cov
          mhash['relevant_lines'] = data.size
          mhash['covered_lines'] = cov
          @total_relevant_lines += data.size
          @total_covered_lines += cov
          @total_missed_lines += data.size - cov

          @measure_coverages[name] =  mhash
        end
      end
      pp @measure_coverages
      lines = @total_relevant_lines # unnecessary but breaks formatting otherwise
      @total_percent_coverage = (@total_covered_lines.to_f / lines.to_f * 100).round(2)
      pp "Total Coverage: #{@total_percent_coverage}"

    end

    def to_hash
      results = {};
      results['total_percent_coverage'] = @total_percent_coverage
      results['total_lines'] = @total_lines
      results['total_relevant_lines'] = @total_relevant_lines
      results['total_covered_lines'] = @total_covered_lines
      results['total_missed_lines'] = @total_missed_lines
      results['by_measure'] = @measure_coverages
      pp results

      results
    end

    def save_results
      res_hash = to_hash
      File.open("#{@path_to_results}/coverage.json", 'w') do |file|
        file << JSON.pretty_generate(res_hash)
      end
    end

  end

end