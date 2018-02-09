# OpenStudio Measure Tester

The OpenStudio Measure Tester is a rubygem that exposes rake tasks for testing OpenStudio measures.

## Installation

* Add the following code to the Gemfile and Rakefile of a measure repo you desire to test.

    * Gemfile
        ```ruby
        gem 'openstudio_measure_tester', '~> 0.1'
        
        # or 
        gem 'openstudio_measure_tester', github: 'NREL/openstudio_measure_tester_gem'
        
        # or
        
        gem 'openstudio_measure_tester', path: '../<path-to-checkout'
        ```
    
    * Rakefile
    
        ```ruby
        require 'openstudio_measure_tester/rake_task'
        OpenStudioMeasureTester::RakeTask.new
        ```
    
* Run `bundle update`
* run `bundle exec rake -T` to see the new tests that are available.
* In existing measure directory, run `bundle exec rake openstudio:test`

## Disclaimer

This project is under active development and will be changing significantly.

## Potential Issues

Currently, the project downloads the rubocops from the OpenStudio-resources Github repo and saves them to the gem's installation location. This may be write protected on some machines.


# TODOS

* Callbacks to gather results
* MiniTest results to JSON (currently only stdout) 