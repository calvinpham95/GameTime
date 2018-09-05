=== Quick Notes ===

We are Code Monkeys, a group of UCLA students who aspire to create the next best thing.

==== Deployment Details ==========

System Requirements:

1. Node
2. MongoDB

After you install Node and MongoDB, open the terminal and run mongod. This starts the mongodb on the system.
Download the source code and go to /backend path

$npm install
To install all the dependencies

$node server.js
The backend starts running on 3000 port and can serve the app

To run some tests, follow these commands
	$ mongod // on one terminal tab
	$ npm test // on another tab


=== Testing Descriptions ===

1. Create New User: test.js - line 32
	-Checks if a new user is created by checking if the message 'User Created' is received

2. Fail to Create New User: test.js - line 43
	-Checks if a new user is not created because they already created by checking if the message 
	'User already present' is received.

3. Return User: test.js - line 59
	-Checks to see if the user can be retrieved through there phone number. Confirm by checking if
	a user is received and they have proper field values.

4. Should Not Return User: test.js - line 77
	-Checks to see if the user cant be retrieved because they arent in the database. Confirm by checking
	that the message 'User Not Found' is received

5. Should Update a Game Object: test.js - line 94
	-Checks to see if the helper function properly udpates a game object. Confirm by checking if an
	existing object in the game database has been updated with new values in fields.

6. Should Not Update a Game Object with undefined data: test.js - line 112
	-Checks to see if the helper function does not update the game object if undefined data is recedived. 
	Confirm by checking that the existing object has the same values.

7. Should Create a Game: test.js - line 130
	-Checks to make sure that a game is created. Confirm by checking that a game was saved with the proper values.

8. Return Game: test.js - line 154
	-Checks to make sure we can retrieve a game from the database with an id. Confirm by checking that the game
	we retrieved has the same values as the game we saved before making api call.

9. Should Return "Game Not Found": test.js - line 177
	-Checks to make sure that we receive the message "Game Not Found", if a game does not exist in the database
	and we are trying to retrieve it.

10. Should Return "Games Not Found": test.js - line 191
	-Checks to make sure that the message "Games Not Found" is received if there are no games in the next seven days
	within the database.

11. Should Return Seven Games: test.js - line 203
	-Checks to make sure that games within the next seven games are returned. Confirm by making sure that
	seven games are returned, where previously we saved 8 games,but only seven were within seven days before 
	making api call.

12. Should Not Return Pot: test.js - line 225
	-Checks to make sure that the message "Pot Not Found" is received if the pot we are looking for
	does not exist in the backend.

13. Should Return Pot: test.js - line 238
	-Checks to make sure that a pot we are looking for is returned. Confirm by making sure that 
	the pot returned has values that match the pot that was saved before making the call.

14. Should Create a New Pot: test.js - line 259
	-Checks to make sure that we receive the message 'A new pot has been successfully created' when
	a new pot has been created.

15. Should create a  new pot and add to activeBets and pendingBets: test.js - line 274
	-Checks to make sure that we receive the message 'A new pot has been successfully created'. That the
	new pot id that is created the id is added to the users activeBets. That the new pot id that is created 
	is added to the pendingBets array of the invited users.g

16. Login returns success: test.js - line 298
	-Login should return "success" if the user is found within the database with there phone number and password

17. Login returns error: test.js - line 302
	-Login should return "error" if the user is not found within the databse with there phone number and password
