Feature: Status Desktop Wallet

    As a user I want to use the wallet

    The feature start sequence is the following (setup on its own `bdd_hooks`):

    ** given A first time user lands on the status desktop and generates new key
    ** when user signs up with username "tester123" and password "TesTEr16843/!@00"
    ** and the user lands on the signed in app
    ** and the user opens the wallet section
    ** and the user accepts the signing phrase

	#############################################
	# WALLET SECTION PART
	#############################################

    Scenario Outline: The user can manage a saved address
        When the user adds a saved address named "<name>" and address "<address>"
        And the user edits a saved address with name "<name>" to "<new_name>"
        Then the name "<new_name>" is in the list of saved addresses

        When the user deletes the saved address with name "<new_name>"
        Then the name "<new_name>" is not in the list of saved addresses

        When the user adds a saved address named "<name>" and ENS name "<ens_name>"
        Then the name "<name>" is in the list of saved addresses

        # Test for toggling favourite button is disabled until favourite functionality is enabled
        # When the user adds a saved address named "<name>" and address "<address>"
        # And the user toggles favourite for the saved address with name "<name>"
        # Then the saved address "<name>" has favourite status "true"
        Examples:
            | name | address                                    | new_name | ens_name |
            | bar  | 0x8397bc3c5a60a1883174f722403d63a8833312b7 | foo      | status.eth |


	#############################################
	# WALLET SETTINGS PART
	#############################################

    Scenario: The user edits the default account
        Given the user opens app settings screen
        And the user opens the wallet settings
        When the user selects the default account
        And the user edits default account to "Default" name and "#FFCA0F" color
        Then the default account is updated to be named "DefaultStatus account" with color "#FFCA0F"
