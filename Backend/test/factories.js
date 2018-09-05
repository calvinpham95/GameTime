var user1 = () => {
	return {
		firstname: "Christopher",
		lastname: "Boshae",
		email: "chrisb@gmail.com",
		phone: 8189550123,
		tokens: 500,
		password: "chrisb",
		activeBets: [],
		pendingBets: [],
		previousBets: [],
		verification: 1
	}
}

var user2 = () => {
	return {
		firstname: "John",
		lastname: "Kim",
		email: "johnk@gmail.com",
		phone: 8189560123,
		tokens: 500,
		password: "johnk",
		activeBets: [],
		pendingBets: [],
		previousBets: [],
		verification: 1
	}
}


var user3 = () => {
	return {
		firstname: "Calvin",
		lastname: "Pham",
		email: "calvinp@gmail.com",
		phone: 8182979939,
		tokens: 500,
		password: "calvinp",
		activeBets: [],
		pendingBets: [],
		previousBets: [],
		verification: 1
	}
}

var game = () => {
	return {
		team1Score: 0,
		team2Score: 0,
		startDate: "2017-11-16",
		team1: "Los Angeles Lakers",
		team2: "Clippers",
		id: "3",
		startTime: "7:00",
		status: ['Not Begin'],
		type: "prm"
	}	
}

var badPot = () => {
	return {
		id: 1,
		acceptedParticipants:[],
		pendingParticipants: [],
		teams: ["lal", "gsw"],
		minBet: 100,
	}
}

var potWithInvites = () => {
	return {
		id: 1,
		acceptedParticipants: [{ uid: 8189550123, amount: 1, team: "Lakers"}],
		pendingParticipants: [8189560123, 8182979939],
		teams: ["lal", "gsw"],
		minBet: 100,
	}
}

var nbaGames = () => {
	var retarr = [];
	var startDate = new Date();
	for(var i = 0; i < 8; i++){
		var tempGame = game();
        var date = new Date();
        date.setDate(startDate.getDate()+i);
        var dateStr = date.getFullYear() + "-" + (date.getMonth()+1) + "-" + date.getDate();
        tempGame.startDate = dateStr;
		tempGame.id = i.toString();
		tempGame.type = "nba";
        retarr.push(tempGame);
    }
    return retarr;
}

var nhlGames = () => {
	var retarr = [];
	var startDate = new Date();
	for(var i = 0; i < 8; i++){
		var tempGame = game();
        var date = new Date();
        date.setDate(startDate.getDate()+i);
        var dateStr = date.getFullYear() + "-" + (date.getMonth()+1) + "-" + date.getDate();
        tempGame.startDate = dateStr;
		tempGame.id = i.toString();
		tempGame.type = "nhl";
        retarr.push(tempGame);
    }
    return retarr;
}

var nflGames = () => {
	var retarr = [];
	var startDate = new Date();
	for(var i = 0; i < 8; i++){
		var tempGame = game();
        var date = new Date();
        date.setDate(startDate.getDate()+i);
        var dateStr = date.getFullYear() + "-" + (date.getMonth()+1) + "-" + date.getDate();
        tempGame.startDate = dateStr;
		tempGame.id = i.toString();
		tempGame.type = "nfl";
        retarr.push(tempGame);
    }
    return retarr;
}

var prmGames = () => {
	var retarr = [];
	var startDate = new Date();
	for(var i = 0; i < 8; i++){
		var tempGame = game();
        var date = new Date();
        date.setDate(startDate.getDate()+i);
        var dateStr = date.getFullYear() + "-" + (date.getMonth()+1) + "-" + date.getDate();
        tempGame.startDate = dateStr;
		tempGame.id = i.toString();
		tempGame.type = "epl";
        retarr.push(tempGame);
    }
    return retarr;
}

module.exports.newGame = game;
module.exports.newUser1 = user1;
module.exports.newUser2 = user2;
module.exports.newUser3 = user3;
module.exports.sevenNBAGames = nbaGames;
module.exports.sevenNHLGames = nhlGames;
module.exports.sevenNFLGames = nflGames;
module.exports.sevenPRMGames = prmGames;
module.exports.newPot = badPot;
module.exports.newPotWithInvites = potWithInvites;