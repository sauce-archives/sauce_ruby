RELEASE NOTES
-------------

3.0.0.beta.1
============

* Removed multiple browsers for RSpec in lieu of magic parallelization via Rake Task
* Added said Rake Task
* Added test brokerage and a runner for Parallel Tests

The plan at the moment is to beta ||ism for RSpec 2, including placing it in the
tutorial and providing beta docs to accompany it.  Once accepted for release,
multiple browsers sequentially will be removed from the integrations.rb file and
we'll recommend parallel testing for everyone.