# GameTime

**Youtube Link**:
<https://www.youtube.com/watch?v=iJffyKxlrZA>

GameTime is a peer to peer betting app that allows you to bet with friends on upcoming basketball, hockey, soccer, and football games.

The project consists of two major segments:

A backend service in NodeJS which manages user onboarding, pot creation/monitoring/settling, getting the upcoming sports games, and "tokens" purchasing.

An iOS frontend which interfaces with our NodeJS application.

External APIs Utilized: Twilio, MySportsFeed, Stripe.


## Backend - NodeJS 

### Deployment Details

System Requirements:

1. Node
2. MongoDB

After you install Node and MongoDB, open the terminal and run the command `mongod`. This starts the mongodb on the system.
After downloading the project repository, in another terminal, navigate to the directory called "backend". Next, run the following commands to start up the NodeJS application - the first command installs all dependencies and the second starts the Node app.

```
npm install
```

```
node server.js
```

The backend starts running on port 3000 and can service the iOS application discussed below.

To run some tests for the Node app, you can run the following command:

```
npm test
```
	
## Frontend - iOS

### Deployment Details

Make sure Xcode is installed on your machine.

After downloading the project repository, navigate to `.../Luck/iOS App/LUCK` within the repository and double click on `LUCK.xcworkspace` to launch the project.

**IMPORTANT CONSIDERATIONS** 
Within the LUCK project folder in the Xcode IDE, look for a file named `LoginViewController.swift`
At the top of the file, please change the 'ipAddress' string to the respective IP address of the machine that the NodeJS application is running on.
