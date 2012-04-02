@selenium
Feature: Serve the best home page ever
  In order to acheive maximum delight
  As a random web user
  I want to see the best home page ever


  Scenario: Locate the best page ever
    Given I am browsing the web
    When I visit "saucelabs.com"
    Then I should be delighted

  Scenario: Locate the not-best page ever
    Given I am browsing the web
    When I visit "oracle.com"
    Then I should not be delighted
