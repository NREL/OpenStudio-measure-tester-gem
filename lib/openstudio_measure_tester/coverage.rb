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
      json_data = File.read(file)
      hash = JSON.parse(json_data)

      # pp hash

      # Sometimes the coverage is RSpec, sometimes MiniTest. Depends if running
      # tests in this Gem, or using this gem where MiniTest is already loaded.
      k, coverage_results = hash.first
      puts "Coverage results are of type #{k}"

      # find all measure names
      measure_names = []
      coverage_results['coverage'].each do |key, data|
        parts = key.split('/')
        if parts.last == 'measure.rb'
          name = parts[-2]
          pp name
          measure_names << name
        end
      end

      measure_names.each do |measure_name|
        cn = ''
        results = coverage_results['coverage'].select { |key, _data| key.include? measure_name }

        mhash = {}
        mhash['total_lines'] = 0
        mhash['relevant_lines'] = 0
        mhash['missed_lines'] = 0
        mhash['covered_lines'] = 0
        mhash['percent_coverage'] = 0
        mhash['files'] = []

        results.each do |key, data|
          fhash = {}
          fhash['name'] = key.partition(measure_name + '/').last
          fhash['total_lines'] = data.size

          # get the class name
          if fhash['name'] == 'measure.rb'
            unless File.exist? key
              # magically try to find the path name by dropping the first element of array
              puts "Trying to determine the file path of unknown measure #{key}"
              key = key.split('/')[1..-1].join('/') until File.exist?(key) || key.split('/').empty?
            end

            # file should exist now
            File.readlines(key).each do |line|
              if (line.include? 'class') && line.split(' ')[0] == 'class'
                cn = line.split(' ')[1].gsub /_?[tT]est\z/, ''
                break
              end
            end
          end

          mhash['total_lines'] += fhash['total_lines']
          # remove nils from array
          data.delete(nil)

          cov = data.count { |x| x > 0 }
          fhash['percent_coverage'] = ((cov.to_f / data.size.to_f) * 100).round(2)
          fhash['missed_lines'] = data.size - cov
          fhash['relevant_lines'] = data.size
          fhash['covered_lines'] = cov

          # measure-level totals
          mhash['relevant_lines'] += fhash['relevant_lines']
          mhash['covered_lines'] += fhash['covered_lines']
          mhash['missed_lines'] += fhash['missed_lines']

          mhash['files'] << fhash
        end
        mhash['percent_coverage'] = (mhash['covered_lines'].to_f / mhash['relevant_lines'].to_f * 100).round(2)
        @measure_coverages[cn] = mhash
        @total_lines += mhash['total_lines']
        @total_relevant_lines += mhash['relevant_lines']
        @total_covered_lines += mhash['covered_lines']
        @total_missed_lines += mhash['missed_lines']
      end

      # pp @measure_coverages
      lines = @total_relevant_lines # unnecessary but breaks formatting otherwise
      # lines can be zero if coverage doesn't run correctly
      if lines != 0
        @total_percent_coverage = (@total_covered_lines.to_f / lines.to_f * 100).round(2)
      end
      pp "Total Coverage: #{@total_percent_coverage}"
    end

    def to_hash
      results = {}
      results['total_percent_coverage'] = @total_percent_coverage
      results['total_lines'] = @total_lines
      results['total_relevant_lines'] = @total_relevant_lines
      results['total_covered_lines'] = @total_covered_lines
      results['total_missed_lines'] = @total_missed_lines
      results['by_measure'] = @measure_coverages
      # pp results

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
