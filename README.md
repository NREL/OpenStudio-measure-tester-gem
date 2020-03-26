# OpenStudio® Measure Tester

[![Gem Version](https://badge.fury.io/rb/openstudio_measure_tester.svg)](https://badge.fury.io/rb/openstudio_measure_tester)

The OpenStudio Measure Tester is a rubygem that exposes rake tasks for testing OpenStudio measures.

## Installation and Running

### Rake-based

* Add the following code to the Gemfile and Rakefile of a measure repo you desire to test.

    * Gemfile
        ```ruby
        source 'https://rubygems.org'
        gem 'openstudio_measure_tester'
        
        # or for release on Github
        gem 'openstudio_measure_tester', github: 'NREL/openstudio_measure_tester_gem', branch: 'develop'
        
        # or for local development
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

### Ruby-based

* Require the OpenStudio-measure-tester gem

   ```ruby
   require 'openstudio_measure_tester'
   measures_dir = 'spec/test_measures/AddOverhangsByProjectionFactor'
   # all measures (recursively) from measures_dir will be tested

   runner = OpenStudioMeasureTester::Runner.new(measures_dir)

   # base_dir is needed for coverage results as they are written to disk on the at_exit calls
   base_dir = Dir.pwd

   result = runner.run_all(base_dir)
   puts result
   # result will be 0 or 1, 0=success, 1=failure

   runner.run_style(false)

   runner.run_test(false, base_dir)

   runner.run_rubocop(false)
   ```

* Results will be saved into the run directory (measures_dir from above).    

## Disclaimer

# Testing in Docker

```bash
apt-get update && apt-get install -y curl
curl -sLO https://raw.githubusercontent.com/NREL/OpenStudio-server/develop/docker/deployment/scripts/install_ruby.sh
curl -sLO https://raw.githubusercontent.com/NREL/OpenStudio-server/develop/docker/deployment/scripts/install_openstudio.sh
chmod +x install_ruby.sh
chmod +x install_openstudio.sh
./install_ruby.sh 2.5.5 28a945fdf340e6ba04fc890b98648342e3cccfd6d223a48f3810572f11b2514c
./install_openstudio.sh 3.0.0 <tdb>
export RUBYLIB=/usr/Ruby
```


# Releasing

* Update change log
* Update version in `/lib/openstudio_measure_tester/version.rb`
* Merge down to master
* Release via github
* run `rake release` from master  
