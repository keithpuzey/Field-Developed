Feature: Application Stress Test

  Scenario: API Stress Test
    Given API Query https://demoblaze.com/prod.html?idp_=
    And 10 users connect
    And the test executes for 2 minutes
    And has a ramp up time of 1 minutes
    When Response time is less than 2s
    Then Response is good

  Scenario: Stress Test using existing JMeter File and cloud reporting
    Given load test called login
    And 10 users connect
    And the test executes for 2 minutes
    And has a ramp up time of 1 minutes
    And Report is generated from the Cloud
    When Response time is less than 5s
    Then Response is good

  Scenario: API Stress Test large number of users
    Given API Query https://demoblaze.com/prod.html?idp_=
    And parameter is 10
    And 10 users connect
    And the test executes for 2 minutes
    And has a ramp up time of 1 minutes
    When Response time is less than 3s
    Then Response is good

  Scenario: API Stress Test with Reports on BlazeMeter
    Given API Data Query http://dbankdemo.com/bank/
    And 15 users connect
    And the test executes for 2 minutes
    And has a ramp up time of 1 minutes
    And Report is generated from the Cloud
    When Response time is less than 5s
    Then Response is good
