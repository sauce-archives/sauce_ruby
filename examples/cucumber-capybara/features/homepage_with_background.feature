@selenium
Feature: Serve the best home page ever
  In order to acheive maximum delight
  As a random web user
  I want to see the best home page ever

  Background:
    Given I am browsing the web
    When I visit "saucelabs.com"

  Scenario: Locate the best page ever
    Then the page should contain a 'Careers' link