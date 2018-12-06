# Version 0.1.7

* Support running measure tester in the directory of the measure.rb with OpenStudio CLI (e.g. `openstudio measure -r .`)

# Version 0.1.6

* Do not require git to run
* Change name of compatibility JSON to the measure name (instead of file name)

# Version 0.1.5

* Run Minitest in foreground
* Remove ActiveSupport XML parsing and use REXML
* Enforce UTF-8 encoding on all files read by this package
* Garbage collection on each Minitest teardown
* Disable running coverage until access violations are resolved
* More logging

# Version 0.1.4

* Use simplecov from NREL's fork. Do not rely on JSON.

# Version 0.1.3

* Catch when infoExtractor is unable to parse measure arguments
* Allow a measure name to include "test"
* Lock down versions of dependencies
* Add a broken measure to the test

# Version 0.1.2

* Do not crash when the current measure is not in a Git repository

# Version 0.1.1

* Check for the existence of the LICENSE.md file in the root of the measures

# Version 0.1

* Initial release of the OpenStudio Tester Gem.
