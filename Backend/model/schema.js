var mongoose = require('mongoose');

var userSchema = new mongoose.Schema({ 
	firstname: String,
	lastname: String,
	password: String,
	email: String,
	phone: Number,
	tokens: Number,
	verification: Number,
	activeBets: [Number],
	pendingBets: [Number],
	previousBets: [{pot_id: Number, date: String, league: String, team1: String, team2: String, betAmount: String, net_profit: String, chosenTeam: String, win: String}], // for completed bets; T = win, F = loss
	channels: [String]
});

var potSchema = new mongoose.Schema({
	id: Number,
	acceptedParticipants: [{ uid: Number, amount: Number, team: String}],
	pendingParticipants: [Number],
	gameId: Number,
	league: {
		type: String,
		enum: ['nfl', 'nba', 'nhl', 'epl'],
		default: 'nba'
	},
	team1: String,
	team2: String,
	pot: Number,
	chatId: String,
	status: {
		type: String,
		enum: ['PRELIM', 'IN-PROGRESS', 'FINISHED'],
		default: 'PRELIM'
	}
});

var gameSchema = new mongoose.Schema({
	team1Score: Number,
	team2Score: Number,
	startDate: String,
	team1: String,
	team2: String,
	id: String,
	startTime: String,
	type: String,
	status: {
		type: String,
		enum: ['Not Begin', 'In Progress', 'Finished'],
		default: ['Not Begin']
	}
});
	
module.exports.userModel = mongoose.model('user',userSchema);
module.exports.potModel = mongoose.model('bet', potSchema);
module.exports.gameModel = mongoose.model('game',gameSchema);
