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
      FileUtils.remove_dir("#{save_dir}/css") if Dir.exist?"#{save_dir}/css"
      FileUtils.remove_dir("#{save_dir}/js") if Dir.exist? "#{save_dir}/js"
      FileUtils.cp_r("#{resource_path}/css", "#{save_dir}/css", remove_destination: true)
      FileUtils.cp_r("#{resource_path}/js", "#{save_dir}/js", remove_destination: true)
    end
  end
end
