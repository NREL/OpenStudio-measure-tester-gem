require "erb"
module OpenStudioMeasureTester
  class Dashboard
    attr_reader :html

    def initialize
      @template = File.read('lib/openstudio_measure_tester/templates/dashboard.html.erb')
      file = File.read('test_results/combined_results.json')
      @data = file
    end

    def render
      rendered = ERB.new(@template, 0, "", "@html").result( binding )
      File.open('dashboard/index.html', 'w') { |file| file.write(rendered) }
    end
  end
end
