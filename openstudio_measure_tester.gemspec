
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'openstudio_measure_tester/version'

Gem::Specification.new do |spec|
  spec.name          = 'openstudio_measure_tester'
  spec.version       = OpenStudioMeasureTester::VERSION
  spec.authors       = ['Nicholas Long']
  spec.email         = ['nicholas.long@nrel.gov']

  spec.summary       = 'Testing framework for OpenStudio measures'
  spec.description   = 'Testing framework for OpenStudio measures'
  spec.homepage      = 'https://openstudio.nrel.gov'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_dependency 'activesupport', '~> 5.1.4'
  spec.add_dependency 'ci_reporter_minitest', '~> 1.0.0'
  spec.add_dependency 'minitest', '~> 5.4.0'
  spec.add_dependency 'minitest-reporters', '~> 1.1'
  spec.add_dependency 'rake', '~> 12.3'
  spec.add_dependency 'rubocop', '~> 0.52'
  spec.add_dependency 'rubocop-checkstyle_formatter', '~> 0.4'
  spec.add_dependency 'simplecov', '~> 0.15'
  spec.add_dependency 'git', '~> 1.3.0'
end
