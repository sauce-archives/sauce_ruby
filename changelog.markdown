# Changelog
## 3.0
### 3.0.2
Strip out extraneous config details from :desired_capabilities

### 3.0.1
Make parallel tests correctly exit when child tests exit with an error.

### 3.0.0
W00t!  Parallelization for Cucumber, RSpec.  The gem now uses parallel_tests to spin up instances of your tests across all specified browsers.  Tests are run at the lower of your concurrency limit OR 20.

Added sauce:install:spec, sauce:install:features to create config helpers
Added parallelization - Gem will now run your tests across multiple browsers and as many threads as you have Sauce VMs
Added sauce:features and sauce:spec to run tests in parallel.

## 2.5
### 2.5.1
Added Test::Unit integration for result reporting
Added better tests for above

### 2.5.0
Added RSpec 2 integration for result reporting.
