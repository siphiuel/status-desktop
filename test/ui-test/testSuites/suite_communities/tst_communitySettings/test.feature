Feature: Community Settings

Background:
	Given A first time user lands on the status desktop and generates new key
	And the user signs up with username "tester123" and password "TesTEr16843/!@00"
	And the user lands on the signed in app
	And the user opens the community portal section
    And the user lands on the community portal section
    And the user creates a community named "Test-Community", with description "My community description", intro "Community Intro" and outro "Community Outro"
    And the user lands on the community named "Test-Community"


 Scenario: Community permissions is an available option is Community Settings
   When "Manage Community" is clicked in the community sidebar
   Then "<settings section>" should be an available option in Community Settings
   	|Members|
   	|Permissions|
   	|Mint Tokens|
   	|Airdrops|