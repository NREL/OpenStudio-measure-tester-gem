# frozen_string_literal: true

########################################################################################################################
#  OpenStudio(R), Copyright (c) 2008-2021, Alliance for Sustainable Energy, LLC. All rights reserved.
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

require 'erb'
module OpenStudioMeasureTester
  class Dashboard
    attr_reader :html

    # @param test_results_directory [String]: The directory
    def initialize(test_results_directory)
      @test_results_directory = test_results_directory

      erb_file = File.expand_path('templates/dashboard.html.erb', File.dirname(__FILE__))
      @template = File.read(erb_file)
      file = File.read("#{@test_results_directory}/combined_results.json")
      @data = file
      @hash = JSON.parse(@data)
    end

    def render
      rendered = ERB.new(@template, 0, '', '@html').result(binding)
      save_dir = "#{@test_results_directory}/dashboard"

      # Render the dashboard
      FileUtils.mkdir_p save_dir unless Dir.exist? save_dir
      File.open("#{save_dir}/index.html", 'w') { |file| file.write(rendered) }
      # copy over all the resource files to display the website correctly.
      resource_path = File.expand_path('../../dashboard', File.dirname(__FILE__))
      # KAF: for some reason, not overwriting the files.  delete them from destination first
      FileUtils.remove_dir("#{save_dir}/css") if Dir.exist? "#{save_dir}/css"
      FileUtils.remove_dir("#{save_dir}/js") if Dir.exist? "#{save_dir}/js"
      FileUtils.cp_r("#{resource_path}/css", "#{save_dir}/css", remove_destination: true)
      FileUtils.cp_r("#{resource_path}/js", "#{save_dir}/js", remove_destination: true)
    end
  end
end
