require "erb"
module OpenStudioMeasureTester
  class Dashboard
    attr_reader :html

    # @param base_dir [String]: The directory from where the rake test was instantiated
    def initialize(base_dir)
      @base_dir = base_dir

      erb_file = File.expand_path('templates/dashboard.html.erb', File.dirname(__FILE__))
      @template = File.read(erb_file)
      file = File.read("#{base_dir}/test_results/combined_results.json")
      @data = file
      @hash = JSON.parse(@data)
    end

    def render
      rendered = ERB.new(@template, 0, "", "@html").result( binding )
      save_dir = "#{@base_dir}/test_results/dashboard"

      # Render the dashboard
      FileUtils.mkdir_p save_dir unless Dir.exist? save_dir
      File.open("#{save_dir}/index.html", 'w') { |file| file.write(rendered) }
      # copy over all the resource files to display the website correctly.
      resource_path = File.expand_path('../../dashboard', File.dirname(__FILE__))
      FileUtils.cp_r("#{resource_path}/css", "#{save_dir}/css", :preserve => true )
      FileUtils.cp_r("#{resource_path}/js", "#{save_dir}/js", :preserve => true )

    end
  end
end
