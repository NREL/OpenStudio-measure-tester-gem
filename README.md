# OpenStudio® Measure Tester

[![Build Status](https://travis-ci.org/NREL/OpenStudio-measure-tester-gem.svg?branch=develop)](https://travis-ci.org/NREL/OpenStudio-measure-tester-gem)
[![Gem Version](https://badge.fury.io/rb/openstudio_measure_tester.svg)](https://badge.fury.io/rb/openstudio_measure_tester)

The OpenStudio Measure Tester is a rubygem that exposes rake tasks for testing OpenStudio measures.

## Installation

* Add the following code to the Gemfile and Rakefile of a measure repo you desire to test.

    * Gemfile
        ```ruby
        source 'https://rubygems.org'
        gem 'openstudio_measure_tester'
        
        # or 
        gem 'openstudio_measure_tester', github: 'NREL/openstudio_measure_tester_gem'
        
        # or
        
        gem 'openstudio_measure_tester', path: '../<path-to-checkout>'
        ```
    
    * Rakefile
    
        ```ruby
        require 'openstudio_measure_tester/rake_task'
        OpenStudioMeasureTester::RakeTask.new
        ```
    
* Run `bundle update`
* run `bundle exec rake -T` to see the new tests that are available.
* In existing measure directory, run `bundle exec rake openstudio:all`
* Minitest, Coverage, Rubocop, and OpenStudio Style will run. The last message that appears to the screen is the location of the dashboard.

    ```
    Open ./test_results/dashboard/index.html to view measure testing dashboard.
    ```

## Disclaimer

This project is under active development and will be changing significantly.

## Potential Issues

Currently, the project downloads the rubocops from the OpenStudio-resources Github repo and saves them to the gem's installation location. This may be write protected on some machines.

# Testing in Docker

```bash

apt-get update && apt-get install -y curl
curl -sLO https://raw.githubusercontent.com/NREL/OpenStudio-server/develop/docker/deployment/scripts/install_ruby.sh
curl -sLO https://raw.githubusercontent.com/NREL/OpenStudio-server/develop/docker/deployment/scripts/install_openstudio.sh
chmod +x install_ruby.sh
chmod +x install_openstudio.sh
./install_ruby.sh 2.2.4 b6eff568b48e0fda76e5a36333175df049b204e91217aa32a65153cc0cdcb761
./install_openstudio.sh 2.4.0 f58a3e1808
export RUBYLIB=/usr/Ruby
```
