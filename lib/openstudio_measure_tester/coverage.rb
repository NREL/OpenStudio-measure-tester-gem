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
  	attr_reader :total_coverage
  	attr_reader :measure_coverages
  	attr_reader :total_lines
  	attr_reader :covered_lines

  	def initialize(path_to_results)
      @path_to_results = path_to_results
      @total_coverage = 0
      @total_lines = 0
      @covered_lines = 0

      @measure_coverages = []

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
	    		# remove nils from array
	    		data.delete(nil)
	    		mhash = {}
	    		mhash['name'] = name
	    		cov = data.count { |x| x > 0 }
	    		mhash['coverage'] = ((cov.to_f / data.size.to_f) * 100).round
	    		@total_lines += data.size
	    		@covered_lines += cov

	    		@measure_coverages << mhash
	    	end
	    end
	    pp @measure_coverages
	    lines = @total_lines # unnecessary but breaks formatting otherwise
	    @total_coverage = (@covered_lines.to_f / lines.to_f * 100).round
	    pp "Total Coverage: #{@total_coverage}"
	    
    end

    def to_json
    	results = {};
    	results['total'] = @total_coverage
    	results['by_measure'] = @measure_coverages
    	pp results

    	results
    end

  end

end