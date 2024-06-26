# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'openstudio_measure_tester/version'

Gem::Specification.new do |spec|
  spec.name = 'openstudio_measure_tester'
  spec.version = OpenStudioMeasureTester::VERSION
  spec.authors = ['Nicholas Long', 'Katherine Fleming', 'Daniel Macumber', 'Robert Guglielmetti']
  spec.email = ['nicholas.long@nrel.gov']

  spec.homepage = 'https://openstudio.nrel.gov'
  spec.summary = 'Testing framework for OpenStudio measures'
  spec.description = 'Testing framework for OpenStudio measures'
  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/NREL/OpenStudio-measure-tester-gem/issues',
    'changelog_uri' => 'https://github.com/NREL/OpenStudio-measure-tester-gem/blob/develop/CHANGELOG.md',
    # 'documentation_uri' =>  'https://www.rubydoc.info/gems/openstudio_measure_tester/#{gem.version}',
    'source_code_uri' => "https://github.com/NREL/OpenStudio-measure-tester-gem/tree/v#{spec.version}"
  }

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 3.2.2'

  spec.add_dependency 'git', '~> 1.12.0'
  spec.add_dependency 'minitest', '~> 5.14.0'
  spec.add_dependency 'minitest-reporters', '~> 1.4.2'
  spec.add_dependency 'rake', '~> 13.0'
  spec.add_dependency 'parser', '3.2.2.2'
  spec.add_dependency 'rubocop', '1.50'
  spec.add_dependency 'rubocop-performance', '1.20.0'
  spec.add_dependency 'rubocop-checkstyle_formatter', '0.6.0'
  spec.add_dependency 'simplecov', '0.22.0'

  spec.add_development_dependency 'bundler', '2.4.10'
  spec.add_development_dependency 'rspec', '~> 3.9'
end
