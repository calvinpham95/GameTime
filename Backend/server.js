/*
 *Importing dependencies from other files
 */
var dbmodule = require('./model/initDB');
var schemas = require('./model/schema');
var utils = require('./util');


/*
 *Importing node dependencies
 */
var express = require('express'),
    bodyParser = require('body-parser'),
    morgan = require('morgan'),
    https = require('https'),
    cron = require('node-cron'),
    asyn = require('async'),
    mongoose = require('mongoose'),
    dateFormat = require('dateformat'),
    twilio = require('twilio');
/*
 *Initialising app and router
 */
var stripe = require('stripe')('sk_test_kqTVlNLg20SniZxQKPT1EmpS')
var mail = require("nodemailer").mail;
var pushy_secret_key ='1290e215614e9ced8e1cd60ad9afe287b3e4a2775a82a43ac1b3f640a52de2d1'
var Pushy = require('pushy');
var pushyAPI = new Pushy(pushy_secret_key);
var data = {
    message: 'Hello World!'
};

var app = express();
var router = express.Router();
app.use(morgan('dev'));
app.use(bodyParser.urlencoded({
    extended: true
}));
app.use(bodyParser.json());
var tokensPerDollar = 100;
var port = process.env.PORT || 3000;
var config = dbmodule.dbConfig;
/*
 *Phone verification
 */
const accountSid = 'AC6d799f0add94e5038ac31752dfefa80e'; 
const authToken = '072132c79e2cd82d8b1be52080b6ffc5';
const twilioNum = '+14243610295';
// ***

const twilioClient = new twilio(accountSid, authToken);

mongoose.connect(config.dburl);
var db = mongoose.connection;

var userSchema = schemas.userModel;
var gameModel = schemas.gameModel;

var firstTime = true;

var startTask = cron.schedule('* * * * * *', function() {
    if(firstTime){
        console.log("Running Start Up Task");
        createsevengamestask();
        updatedailygames("nba");
        updatedailygames("nhl");
        updatedailygames("nfl");
        updatesoccergames();
    }

    firstTime = false;
}, true);

startTask.start();

var updateTask = cron.schedule('*/5 * * * *', function() {
    updatedailygames("nba");
    updatedailygames("nhl");
    updatedailygames("nfl");
    updatesoccergames();

}, true);

updateTask.start();

var updatePotTask = cron.schedule('*/5 * * * *', function () {
    console.log("checking pots...")
    potSchema.find({}, function(err, pots) {
        for (var i = 0; i < pots.length; i++) {
            updatePot(pots[i])
        }
    });
    console.log("finished checking pots")
}, true);

updatePotTask.start();

var createGamesTask = cron.schedule('0 0 0 * * *', function() {
    createsevengamestask();
}, true);

createGamesTask.start();

function updatePot(potObj) {
    gameModel.findOne({
        id: potObj.gameId
    }, function(err, gameObj) {
        if (gameObj == null) {
            return // means we couldn't find the game at all...
        }
        if (gameObj.status == 'In Progress' && potObj.status !== "IN-PROGRESS") {
            if (potObj.acceptedParticipants.length == 1) {
                userSchema.findOne({phone: potObj.acceptedParticipants[0].uid}, (err,user) => {
                    var index = user.activeBets.indexOf(potObj.id);
                    user.activeBets.splice(index,1);
                    user.save((err) => {
                        if (err)
                            console.log("Error saving user");
                    })
                });

                potObj.remove({
                    id: potObj.id
                }, function (err) {
                    if (err) {
                         throw err; 
                        }
                });
            } else {
                potObj.status = 'IN-PROGRESS';
                potObj.save(function (err) {
                    if (err) 
                        throw err
                });
            }
        } else if (gameObj.status == 'Finished' && potObj.status !== "FINISHED") {
            var d = new Date();
            userSchema.find({
                activeBets: potObj.id
            }, function (err, userObjs) {
                // get these two sums
                var sum_of_all_bets = 0
                var sum_of_all_win_bets = 0
                // winning team
                var winningTeam = gameObj.team1
                if (gameObj.score1 < gameObj.score2) 
                    winningTeam = gameObj.team2
                // win bets
                var amounts = []
                var teams = []
                for (var i = 0; i < potObj.acceptedParticipants.length; i++) {
                    if (potObj.acceptedParticipants[i].team == winningTeam) {
                        sum_of_all_win_bets += potObj.acceptedParticipants[i].amount
                    }
                    sum_of_all_bets += potObj.acceptedParticipants[i].amount
                    amounts.push(potObj.acceptedParticipants[i].amount)
                    teams.push(potObj.acceptedParticipants[i].team)
                }
                // now apply weighted average...
                for (var i = 0; i < potObj.acceptedParticipants.length; i++) {
                    for (var j = 0; j < userObjs.length; j++) {
                        if (potObj.acceptedParticipants[i].uid == userObjs[j].phone) {
                            var hasWon = potObj.acceptedParticipants[i].team == winningTeam
                            var earnings = Math.round(potObj.acceptedParticipants[i].amount * (sum_of_all_bets / sum_of_all_win_bets)) // or floor
                            if (hasWon) userObjs[j].tokens += earnings
                            // remove old bet
                            for (var k = 0; k < userObjs[j].activeBets.length; k++) {
                                if (userObjs[j].activeBets[k] == potObj.id) {
                                    userObjs[j].activeBets.splice(k, 1)
                                    break
                                }
                            }
                            // add bet to history of each participating user
                            if (!hasWon) earnings = -amounts[i];

                            userObjs[j].previousBets.push({
                                pot_id: potObj.id,
                                date: dateFormat(d, "isoDate"),
                                league: potObj.league,
                                team1: potObj.team1,
                                team2: potObj.team2,
                                betAmount: amounts[i].toString(),
                                net_profit: earnings.toString(),
                                chosenTeam: teams[i],
                                win: hasWon.toString()
                            });

                            userObjs[j].save(function (err) {
                                if (err) throw err
                            });

                            break
                        }
                    }
                }
                potObj.status = "FINISHED"
                potObj.save(function (err) {
                    if (err) throw err
                });
            });
        }
    });
}

var updateGame = (score1, score2, identification, s) => {
    const updatedGame = {
        team1Score: score1,
        team2Score: score2,
        status: [s]
    }

    gameModel.update({
        id: identification
    }, updatedGame, {}, () => {});
}

var createGame = (startDate, team1, team2, identification, t, type, callbck) => {
    var gameObj = new gameModel();

    gameModel.find({
        id: identification
    }, (err, games) => {
        if (!games.length) {
            gameObj.team1Score = 0;
            gameObj.team2Score = 0;
            gameObj.startDate = startDate;
            gameObj.team1 = team1;
            gameObj.team2 = team2;
            gameObj.id = identification;
            gameObj.startTime = t;
            gameObj.type = type;
            gameObj.save((err) => {
                callbck();
            });
        }
    });
}

function updatesoccergames() {
    console.log("UPDATING SOCCER GAMES");
    var date = new Date();
    var soccerDateStr = date.getFullYear() + "-" + (date.getMonth() + 1) + "-" + date.getDate();
    var apiRequestStr = 'https://apifootball.com/api/?action=get_events&from=' + soccerDateStr + '&to=' + soccerDateStr + '&APIkey=689f00e285236d3fc0af2203cb21c484878d7d76ec2f4c0134da36d94595311d';
    var data = '';
    
    console.log(apiRequestStr);

    https.get(apiRequestStr, (resp) => {
        resp.on('data', (chunk) => {
            data += chunk;
        });
        resp.on('end', () => {
            var games= JSON.parse(data);


            for (var i = 0; i < games.length; i++) {
                if(games[i].league_name === "Premier League"){
                    if (games[i].match_hometeam_score !== "?")
                        var status = 'In Progress';
                    else if (games[i].match_status === "FT")
                        var status = 'Finished';
                    else
                        var status = 'Not Begin';

                    var score1 = isNaN(parseInt(games[i].match_hometeam_score)) ? 0 : parseInt(games[i].match_hometeam_score);
                    var score2 = isNaN(parseInt(games[i].match_awayteam_score)) ? 0 : parseInt(games[i].match_awayteam_score);
 
                    updateGame(score1, score2, games[i].match_id, status);
                }  
            }


        });
    }).on("error", (err) => {
        console.log("Error: " + err.message);
    });
}

/*
Method to periodically update the games coming up in the next seven days
*/
function updatedailygames(type) {
    console.log("UPDATING GAMES");
    var todaysDate = new Date();
    var dateStr = todaysDate.getFullYear() + "" + (todaysDate.getMonth() + 1) + "" + todaysDate.getDate();
    var apiRequestStr = 'https://anirudhnarayan:anirudh123@api.mysportsfeeds.com/v1.1/pull/' + type + '/2017-2018-regular/scoreboard.json?fordate=' + dateStr;
    var data = '';
    
    console.log(apiRequestStr);

    https.get(apiRequestStr, (resp) => {
        resp.on('data', (chunk) => {
            data += chunk;
        });
        resp.on('end', () => {
            var scoreboardData = JSON.parse(data);
            

            if(scoreboardData === null || scoreboardData.scoreboard === null){
                console.log("No Score Data Available");
            }
            else{
                gameScores = scoreboardData.scoreboard.gameScore;
                for (var i = 0; gameScores && i < gameScores.length; i++) {

                    if (gameScores[i].isInProgress === "true")
                        var status = 'In Progress';
                    else if (gameScores[i].isCompleted === "true")
                        var status = 'Finished';
                    else
                        var status = 'Not Begin';

                    updateGame(gameScores[i].awayScore, gameScores[i].homeScore, gameScores[i].game.ID, status);
                }
            }

        });
    }).on("error", (err) => {
        console.log("Error: " + err.message);
    });
}

function createsevengamestask() {
    console.log("Checking next seven days for games");
    var startDate = new Date();
    for (var i = 0; i < 7; i++) {
        var date = new Date();
        date.setDate(startDate.getDate() + i);

        var dateStr = date.getFullYear() + "" + (date.getMonth() + 1) + "" + date.getDate();

        var soccerDateStr = date.getFullYear() + "-" + (date.getMonth() + 1) + "-" + date.getDate();

        savegames(dateStr, 'nba');
        savegames(dateStr, 'nhl');
        savegames(dateStr, 'nfl');
        savesoccergames(soccerDateStr);
    }
}


function savesoccergames (date){
    var apiRequestStr = 'https://apifootball.com/api/?action=get_events&from=' + date + '&to=' + date + '&APIkey=689f00e285236d3fc0af2203cb21c484878d7d76ec2f4c0134da36d94595311d';
    var data = '';

    https.get(apiRequestStr, (resp) => {
        resp.on('data', (chunk) => {
            data += chunk;
        });

        resp.on('end', () => {


            var games = JSON.parse(data);


            if (games == undefined || games.length == 0 || games.length == undefined) {
                console.log("Error: Premier Soccer Games Unavailable For " + date);
            } else {
                for (var i = 0; i < games.length; i++) {
                    if(games[i].league_name === "Premier League"){
                        var startDate = games[i].match_date;
                        var team1 = games[i].match_hometeam_name.replace("amp;", "");
                        var team2 = games[i].match_awayteam_name.replace("amp;", "");
                        var identification = games[i].match_id;
                        var time = timeConverter(games[i].match_time);
                        createGame(startDate, team1, team2, identification, time, "epl",  () => {});
                    }
                }
            }

        });

    }).on("error", (err) => {
        console.log("Error: " + err.message);
    });
}

function timeConverter(timeString){
    var H = timeString.substr(0, 2);
    var h = H % 12 || 12;
    var ampm = (H < 12 || H === 24) ? "AM" : "PM";
    return h + timeString.substr(2, 3) + ampm;
}


function savegames(date, type) {
    var apiRequestStr = 'https://anirudhnarayan:anirudh123@api.mysportsfeeds.com/v1.1/pull/' + type + '/2017-2018-regular/daily_game_schedule.json?fordate=' + date;
    var data = '';
    https.get(apiRequestStr, (resp) => {
        resp.on('data', (chunk) => {
            data += chunk;
        });

        resp.on('end', () => {
            var games = undefined;
            if(data !== undefined)
                games = JSON.parse(data);

            if (games == undefined || games.dailygameschedule == undefined){
                var entries = undefined;
            }
            else{
                var entries = games.dailygameschedule.gameentry;
            }
            
            if (entries == undefined || entries.length == 0) {
                console.log("Error: No entries in games.dailygameschedule.gameentry of savegames");
            } else {
                for (var i = 0; i < entries.length; i++) {
                    var startDate = entries[i].date;
                    var team1 = entries[i].awayTeam.Name;
                    var team2 = entries[i].homeTeam.Name;
                    var identification = entries[i].id;
                    var time = entries[i].time;
                    createGame(startDate, team1, team2, identification, time, type,  () => {});
                }
            }
        });

    }).on("error", (err) => {
        console.log("Error: " + err.message);
    });
}

var potSchema = schemas.potModel;

/**
 * @api {get} /pot/getPot/:id Get Pot
 * @apiName getPot
 * @apiGroup Pot
 * @apiPermission none
 * 
 * @apiDescription Get a pot object. 
 * 
 * @apiParam {Number} pid Pot ID
 * @apiParamExample {json} Request-Example:
 *     {
 *       "pid": 1
 *     }
 * 
 * @apiSuccess {Number}     id                      Pot id
 * @apiSuccess {Object[]}   acceptedParticipants    List of accepted participants, each containing phone number, amount bet, and team chosen
 * @apiSuccess {Number[]}   pendingParticipants     List of pending participants
 * @apiSuccess {Number}     gameId                  Id of the game
 * @apiSuccess {String}     team1                   Team 1 of game
 * @apiSuccess {String}     team2                   Team 2 of game
 * @apiSuccess {Number}     pot                     Total number of tokens in pot
 * @apiSuccess {Number}     chatId                  The chatroom ID
 * @apiSuccess {String}     status                  Current status, one of "PRELIM", "INVALID", "IN-PROGRESS", and "FINISHED"
 *
 * @apiSuccessExample {json} Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *          "id": 2,
 *          "acceptedParticipants": [
 *              {
 *                  "uid": 1,
 *                  "amount": 100,
 *                  "team": "Los Angeles Lakers",
 *              }
 *          ],
 *          "pendingParticipants": [
 *              2,
 *              3
 *          ],
 *          "team1": "Los Angeles Lakers,
 *          "team2": "Clippers"
 *          "pot": 100,
 *          "chatId": 12,
 *          "status": "PRELIM"
 *      }
 * 
 * @apiError PotNotFound The id of the pot was not found.
 * @apiErrorExample Error-Response:
 *     HTTP/1.1 404 Not Found
 *     {
 *       "message": "Pot Not Found"
 *     }
 */
router.get('/pot/getPot/:pid', function(req, res) {
    potSchema.findOne({
        id: req.params.pid
    }, function(err, potObj) {
        if (!potObj)
            res.send({
                message: "Pot Not Found"
            })
        else if (err)
            res.send(err);
        else
            res.json(potObj);
    });
});
/**
 * @api {post} /pot/createPot/ Create a Pot
 * @apiName createPot
 * @apiGroup Pot
 * 
 * @apiDescription Creates a pot. Note that when a user creates a pot,
 * he is automatically an accepted participant. All his invitees are in the pending
 * participants. An object of acceptedParticipants has parameters uid, amount, team and
 * should have only one element, which is the creator. The pot automatically starts on 
 * the creator's amount tokens and its status is automatically set to "PRELIM".
 * For acceptedParticipants, pendingParticipants, and teams, please define an array with value(s) in them. 
 * 
 * @apiParam {Number}     id                      Pot ID
 * @apiParam {Object[]}   acceptedParticipants    List of accepted participants, with only one participant ({phone, amount, team})
 * @apiParam {Number[]}   pendingParticipants     List of pending participants
 * @apiParam {Number}     gameId                  Id of game
 * @apiParam {String}     chatId                  Id of chatroom
 * @apiParam {String}     league                  League that game is in, one of ['nba', 'nfl, 'nhl', 'epl']
 *
 * @apiParamExample {json} Request-Example:
 *  {
 *      "id": 1,
 *      "acceptedParticipants": [{"uid: 15, "amount": 100, "team": "Los Angeles Lakers"}],
 *      "pendingParticipants": [14, 200, 11, 17],
 *      "gameId": 2,
 *      "chatId": 30,
 *      "league": "nba"
 *  }
 * 
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *          "message": "a new pot has been successfully created"
 *     }
 */
router.post('/pot/createPot', function(req, res) {
    var potObj = new potSchema(req.body);
    // set active bet for user who started the pot
    if (potObj.acceptedParticipants.length == 1) {
        userSchema.findOne({
            phone: potObj.acceptedParticipants[0].uid
        }, function(err, userObj) {
            if (err) res.send(err)
            if (userObj.verification != 1) {
                res.send({
                    "error": "User is not yet verified!"
                })
            }
            userObj.activeBets.push(potObj.id)
            if (userObj.tokens - req.body.acceptedParticipants[0].amount < 0) {
                res.send({
                    "error": "User does not have enough tokens to make this bet"
                })
            } else {
                userObj.tokens -= req.body.acceptedParticipants[0].amount // deduct money from the better.
                userObj.save((err) => {
                    if (err) res.send(err)
                });
                potObj.pot = req.body.acceptedParticipants[0].amount
                // set pending bets for invitees
                for (var i = 0; i < potObj.pendingParticipants.length; i++) {
                    userSchema.findOne({
                        phone: potObj.pendingParticipants[i]
                    }, function(err, userObj) {
                        if (err) 
                            res.send(err)
                        userObj.pendingBets.push(potObj.id)
                        userObj.save(function(err) {
                            if (err) 
                                res.send(err)
                        })
                    })
                }

                gameModel.findOne({id: potObj.gameId + ""}, (err,game) => {
                    if(err)
                        console.log("error");
                    else{
                        if(game !== undefined){
                            potObj.team1 = game.team1;
                            potObj.team2 = game.team2;
                            
                            potObj.save(function(err) {
                                if (err)
                                    res.send(err)
                                else
                                    res.send({
                                        "message": "A new pot has been successfully created"
                                    })
                            });
                        }
                    }
                });

            }
        });
    } else {
        res.send({
            "error": "There can only be one accepted better when creating the pot"
        })
    }
});
/**
 * @api {post} /pot/inviteeAcceptsSimple/ Invitee accepts invite
 * @apiName inviteeAcceptsSimple
 * @apiGroup Pot
 * 
 * @apiDescription A pending participant for a pot accepts the invitation,
 * and upon entering, he pays the minimum bet. If his balance is less than
 * the minimum bet, he cannot enter. This is for the simple model.
 * 
 * @apiParam {Number} pid Pot ID
 * @apiParam {Number} uid User ID (i.e. phone)
 * @apiParam {Number} bet Amount the user is betting
 * @apiParam {String} team Team that user is betting on
 * 
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *          "message": "Pending participant has successfully accepted invite"
 *     }
 */
router.post('/pot/inviteeAcceptsSimple', function(req, res) {
    potSchema.findOne({
        id: req.body.pid
    }, function(err, potObj) {
        userSchema.findOne({
            phone: req.body.uid,
            pendingBets: req.body.pid
        }, function(err, userObj) {
            if (userObj.verification != 1) {
                res.send({
                    "error": "Participant must be verified to participate"
                })
            }
            if (userObj.tokens < potObj.minBet) {
                res.send({
                    "error": "Participant doesn't have the money to make this bet"
                })
            } else if (potObj.status != "PRELIM") {
                res.send({
                    "error": "Pot is not in the betting stage"
                })
            } else {
                var movedToAccepted = false
                // no longer pending participant in pot
                for (var i = 0; i < potObj.pendingParticipants.length; i++) {
                    if (potObj.pendingParticipants[i] == req.body.uid) {
                        potObj.pendingParticipants.splice(i, 1)
                        movedToAccepted = true
                        break
                    }
                }
                if (movedToAccepted) {
                    // no longer a pending bet for user
                    for (var i = 0; i < userObj.pendingBets.length; i++) {
                        if (userObj.pendingBets[i] == potObj.id) {
                            userObj.pendingBets.splice(i, 1);
                            break
                        }
                    }
                    // pot now goes to user's active bets, pot recognizes user as participant
                    // Between the old and new, all that is changed is minBet --> req.body.bet
                    if (userObj.tokens - req.body.bet < 0) {
                        res.send({
                            "error": "User does not have enough tokens to make this bet"
                        })
                    } else {
                        userObj.tokens -= req.body.bet
                        userObj.activeBets.push(potObj.id)
                        potObj.pot += req.body.bet
                        potObj.acceptedParticipants.push({
                            uid: userObj.phone,
                            amount: req.body.bet,
                            team: req.body.team
                        })
                        potObj.save(function(err) {
                            if (err) res.send(err)
                            userObj.save(function(err) {
                                if (err) res.send(err)
                                res.send({
                                    "message": "Pending participant has successfully accepted invite"
                                })
                            });
                        });
                    }
                } else {
                    res.send({
                        "error": "User was never invited to this pot"
                    })
                }
            }
        });
    });
});
/**
 * @api {post} /pot/inviteeRejects/ Invitee rejects invite
 * @apiName inviteeRejects
 * 
 * @apiDescription Invitee rejects the invitation to bet, thereby removing 
 * this pending bet from the user object.
 * 
 * @apiGroup Pot
 * @apiParam {Number} pid Pot ID.
 * @apiParam {Number} uid User ID.
 * 
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *          "message": "Invitee has been successfully removed"
 *     }
 */
router.post('/pot/inviteeRejects', function(req, res) {
    potSchema.findOne({
        id: req.body.pid
    }, function(err, potObj) {
        var foundInvitee = false
        for (var i = 0; i < potObj.pendingParticipants.length; i++) {
            if (potObj.pendingParticipants[i] == req.body.uid) {
                foundInvitee = true
                potObj.pendingParticipants.splice(i, 1)
                userSchema.findOne({
                    phone: req.body.uid,
                    pendingBets: req.body.pid
                }, function(err, userObj) {
                    // no longer a pending bet for user
                    for (var i = 0; i < userObj.pendingBets.length; i++) {
                        if (userObj.pendingBets[i] == potObj.id) {
                            userObj.pendingBets.splice(i, 1)
                            break
                        }
                    }
                    userObj.save(function(err) {
                        if (err) res.send(err)
                    })
                });
                break
            }
        }
        if (foundInvitee) {
            potObj.save(function(err) {
                if (err) res.send(err)
                res.send({
                    "message": "Invitee has been successfully removed"
                })
            });
        } else {
            res.send({
                "error": "Invitee was not found!"
            })
        }

    });
});
/**
 * @api {get} /game/getSevenDayNBAGames/ NBA Seven Day Games
 * @apiName getNBAWeeklyGameData
 * @apiGroup Game
 *
 * @apiDescription Gets information about the next seven days worth of games
 * There are no parameters to make this request.
 * 
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *          // list of game objects for next seevn days from time of call
 *     }
 *
 * @apiError GamesNotFound Games were not found
 *
 * @apiErrorExample Error-Response:
 *     HTTP/1.1 404 Not Found
 *     {
 *       "message": "Games Not Found"
 *     }
 */
router.get('/game/getSevenDayNBAGames/', function(req, res) {
    var beginDate = new Date();
    var endDate = new Date();
    endDate.setDate(beginDate.getDate() + 6);

    var beginCondition = dateFormat(beginDate, "isoDate");
    var endCondition = dateFormat(endDate, "isoDate");

    gameModel.find({
        startDate: {
            $gte: beginCondition,
            $lte: endCondition
        },
        type: "nba"
    }, (err, game) => {
        if (err)
            res.send({
                "message": "Error Occurred"
            });
        else if (!game.length)
            res.send({
                "message": "Games Not Found"
            });
        else{
            game.sort((a,b) => a.startDate == b.startDate ? 0 : a.startDate > b.startDate ? 1 : -1);

            res.json(game.filter((g) => g.status === "Not Begin"));
        }

    });
});
/**
 * @api {get} /game/getSevenDayNHLGames/ NHL Seven Day Games
 * @apiName getSevenDayNHLGames
 * @apiGroup Game
 *
 * @apiDescription Gets information about the next seven days worth of games for NHL.
 * There are no parameters to make this request.
 * 
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *          // list of game objects for next seevn days from time of call
 *     }
 *
 * @apiError GamesNotFound Games were not found
 *
 * @apiErrorExample Error-Response:
 *     HTTP/1.1 404 Not Found
 *     {
 *       "message": "Games Not Found"
 *     }
 */
router.get('/game/getSevenDayNHLGames/', function(req, res) {
    var beginDate = new Date();
    var endDate = new Date();
    endDate.setDate(beginDate.getDate() + 6);

    var beginCondition = dateFormat(beginDate, "isoDate");
    var endCondition = dateFormat(endDate, "isoDate");

    gameModel.find({
        startDate: {
            $gte: beginCondition,
            $lte: endCondition
        },
        type: "nhl"
    }, (err, game) => {
        if (err)
            res.send({
                "message": "Error Occurred"
            });
        else if (!game.length)
            res.send({
                "message": "Games Not Found"
            });
        else{
            game.sort((a,b) => a.startDate == b.startDate ? 0 : a.startDate > b.startDate ? 1 : -1);
            res.json(res.json(game.filter((g) => g.status === "Not Begin")));
        }

    });
});
/**
 * @api {get} /game/getSevenDayNFLGames/ NFL Seven Day Games
 * @apiName getNFLWeeklyGameData
 * @apiGroup Game
 *
 * @apiDescription Gets information about the next seven days worth of games for NFL.
 * There are no parameters to make this request.
 * 
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *          // list of game objects for next seven days from time of call
 *     }
 *
 * @apiError GamesNotFound Games were not found
 *
 * @apiErrorExample Error-Response:
 *     HTTP/1.1 404 Not Found
 *     {
 *       "message": "Games Not Found"
 *     }
 */
router.get('/game/getSevenDayNFLGames/', function(req, res) {
    var beginDate = new Date();
    var endDate = new Date();
    endDate.setDate(beginDate.getDate() + 6);

    var beginCondition = dateFormat(beginDate, "isoDate");
    var endCondition = dateFormat(endDate, "isoDate");

    gameModel.find({
        startDate: {
            $gte: beginCondition,
            $lte: endCondition
        },
        type: "nfl"
    }, (err, game) => {
        if (err)
            res.send({
                "message": "Error Occurred"
            });
        else if (!game.length)
            res.send({
                "message": "Games Not Found"
            });
        else{
            game.sort((a,b) => a.startDate == b.startDate ? 0 : a.startDate > b.startDate ? 1 : -1);
            res.json(game.filter((g) => g.status === "Not Begin"));
        }

    });
});
/**
 * @api {get} /game/getSevenDayPremierGames/ Premier Seven Day Games
 * @apiName getEPLWeeklyGameData
 * @apiGroup Game
 *
 * @apiDescription Gets information about the next seven days worth of games for EPL.
 * There are no parameters to make this request.
 * 
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *          // list of game objects for next seven days from time of call
 *     }
 *
 * @apiError GamesNotFound Games were not found
 *
 * @apiErrorExample Error-Response:
 *     HTTP/1.1 404 Not Found
 *     {
 *       "message": "Games Not Found"
 *     }
 */
router.get('/game/getSevenDayPremierGames/', function(req, res) {
    var beginDate = new Date();
    var endDate = new Date();
    endDate.setDate(beginDate.getDate() + 6);

    var beginCondition = dateFormat(beginDate, "isoDate");
    var endCondition = dateFormat(endDate, "isoDate");

    gameModel.find({
        startDate: {
            $gte: beginCondition,
            $lte: endCondition
        },
        type: "epl"
    }, (err, game) => {
        if (err)
            res.send({
                "message": "Error Occurred"
            });
        else if (!game.length)
            res.send({
                "message": "Games Not Found"
            });
        else{
            game.sort((a,b) => a.startDate == b.startDate ? 0 : a.startDate > b.startDate ? 1 : -1);
            res.json(game.filter((g) => g.status === "Not Begin"));
        }

    });
});

/*DO NOT DELETE THIS ROUTE. IT IS FOR TESTING PURPOSES*/
router.get('/game/removeAllGames/', function(req, res) {
    gameModel.remove({}, (err) => { 
        if(err)
           res.send({
                "message": "Error Occurred"
            }); 
        else
            res.send({
                "message": "Removed All Games"
            });     
    }); 
});

/**
 * @api {get} /game/getGame/:id Request Game information
 * @apiName getGame
 * @apiGroup Game
 *
 * @apiDescription Get information about a particular game
 * 
 * @apiParam {Number} id Unique game ID.
 * 
 * @apiSuccess {Number} team1Score  Score of Team 1
 * @apiSuccess {Number} team2Score  Score of Team 2
 * @apiSuccess {String} startDate   Start date
 * @apiSuccess {String} team1       Name of Team 1
 * @apiSuccess {String} team2       Name of Team 2
 * @apiSuccess {String} id          Game ID
 * @apiSuccess {String} startTime   Start time
 * @apiSuccess {String} status      One of "Not Begin", "In Progress", and "Finished"
 * 
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *      "team1Score": 50,
 *      "team2Score": 49,
 *      "startDate": "2017-11-05"
 *      "team1": "Los Angeles Lakers",
 *      "team2": "Golden State Warriors",
 *      "id": "15",
 *      "startTime": "7:00PM",
 *      "status": "Not Begin"
 *     }
 *
 * @apiError GameNotFound The id of the game was not found.
 *
 * @apiErrorExample Error-Response:
 *     HTTP/1.1 404 Not Found
 *     {
 *       "message": "Game Not Found"
 *     }
 */
router.get('/game/getGame/:id', function(req, res) {
    gameModel.find({
        id: req.params.id
    }, (err, game) => {
        if (err)
            res.send({
                "message": "Error Occurred"
            });
        else if (!game.length)
            res.send({
                "message": "Game Not Found"
            });
        else
            res.json(game[0]);
    });
});
/**
 * @api {get} /game/getGames Get games
 * @apiName getGames
 * @apiGroup Game
 *
 * @apiDescription Get all games
 * 
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *          // a list of all the games
 *     }
 */
router.get('/game/getGames', function(req, res) {
    gameModel.find({}, (err, games) => {
        if (err)
            res.send({
                "message": "Error Occurred"
            });
        else if (!games.length)
            res.send({
                "message": "Game Not Found"
            });
        else
            res.json(games);
    });
});
/**
 * @api {post} /user/registerUser/ Register a new User
 * @apiName registerUser
 * @apiGroup User
 *
 * @apiDescription Register a new user into the system. After that, send a 
 * verification code to the user (a number between 1000 and 9999 inclusive).
 * 
 * @apiParam {String} firstname User's first name
 * @apiParam {String} lastname User's last name
 * @apiParam {String} email User's email
 * @apiParam {Number} phone User's phone number. This is also the User's unique id
 * @apiParam {string} password User password
 *
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *       "message": "Registering Successful"
 *     }
 *
 * @apiErrorExample Error-Response:
 *     HTTP/1.1 404 Not Found
 *     {
 *       "message": "User already present"
 *     }
 */
router.post('/user/registerUser', (req, res) => {
    var usermodel = schemas.userModel
    var userObj = new usermodel(req.body)
    userObj.tokens = 500

    db.collection("users").find({
        "phone": req.body.phone
    }).toArray(function(err, result) {
        if (result.length == 0) {
            var code = Math.floor(1000 + Math.random() * 9000);
            userObj.verification = code;
            userObj.save(function(err) {
                if (err) {
                    res.send(err);
                }
                console.log('+1' + req.body.phone)
                twilioClient.messages.create({
                    to: '+1' + req.body.phone,
                    from: twilioNum,
                    body: 'Your Game Time verification code is: ' + code
                }, function(twilioerr) {
                    if (twilioerr) {
                        userObj.remove({
                            "phone": req.body.phone
                        }, function(remerr) {
                            if (remerr) {
                                throw remerr;
                            }
                        });
                        res.json({
                            message: 'Invalid phone number!'
                        });
                    } else {
                        res.json({
                            message: 'Success! User Created. Verification code sent.'
                        });
                    }
                });
            });
        } else {
            res.json({
                message: 'User already present'
            });
        }
    });
});
/**
 * @api {post} /user/checkVerified/ Verify or check that user is verified
 * @apiName checkVerified
 * @apiGroup User
 *
 * @apiDescription Verify the user or check that the user is verified. 
 * If code parameter is not provided, it does a verification check. Otherwise,
 * it verifies the user based on whether the code is correct or not.
 * 
 * @apiParam {Number} phone User's phone number
 * @apiParam {Number} code (optional) a 4-digit verification code
 *
 * @@apiParamExample {json} Request-Example:
 *     {
 *       "phone": 2134445555
 *       "code": 1234
 *     }
 *
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *       "message": "Success! User is now verified"
 *     }
 * 
 * @apiParamExample {json} Request-Example:
 *     {
 *       "phone": 2134445555
 *     }
 *
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *       "message": "User is already verified"
 *     }
 */
router.post('/user/checkVerified', (req, res) => {
    userSchema.findOne({
        "phone": req.body.phone
    }, (err, userObj) => {
        if (userObj == null) {
            res.json({
                error: "User Not Found"
            });
        } else {
            // for simplicity, verification = 1 indicates verified
            if (userObj.verification == 1) {
                res.json({
                    error: 'User is already verified'
                });
            } else {
                if (req.body.code == null && userObj.verification != 1) {
                    res.json({
                        message: 'User is not verified'
                    })
                } else if (userObj.verification == req.body.code) {
                    userObj.verification = 1
                    userObj.save(function (err) {
                        if (err) {
                            res.send(err);
                        }
                        res.json({
                            message: 'Success! User is now verified'
                        });
                    });
                } else {
                    res.json({
                        error: 'Wrong verification code'
                    });
                }
            }

        }
    });
});
/**
 * @api {post} /user/resendVerification/ Resend verification code
 * @apiName resendVerification
 * @apiGroup User
 *
 * @apiDescription If the user exists but is not yet verified,
 * provide a new 4-digit code.
 * 
 * @apiParam {Number} phone User's phone number
 *
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *          "message": "New verification code sent"
 *     }
 */
router.post('/user/resendVerification', (req, res) => {
    userSchema.findOne({
        "phone": req.body.phone
    }, (err, userObj) => {
        if (userObj == null) {
            res.json({
                error: "User Not Found"
            });
        } else if (userObj.verification == 1) {
            res.json({
                error: "User has already been verified"
            });
        } else {
            var code = Math.floor(1000 + Math.random() * 9000);
            userObj.verification = code;
            userObj.save(function(err) {
                if (err) {
                    res.send(err);
                }
                twilioClient.messages.create({
                    to: '+1' + req.body.phone,
                    from: twilioNum,
                    body: 'Your new Game Time verification code is: ' + code
                }, function(twilioerr) {
                    if (twilioerr) {
                        res.send(err);
                    } else {
                        res.json({
                            message: 'Success! New verification code sent'
                        });
                    }
                });
            });
        }
    });
});
/**
 * @api {get} /user/getUserProfile/:uid Get User profile
 * @apiName getUserProfile
 * @apiGroup User
 *
 * @apiDescription Get user profile information
 * 
 * @apiParam {Number} uid User's unique ID.
 *
 * @apiSuccess {String} firstname First name of the User
 * @apiSuccess {String} lastname  Last name of the User
 * @apiSuccess {String} password  Password of the User (sensitive info!)
 * @apiSuccess {Number} phone  10-digit phone number of the User
 * @apiSuccess {Number} tokens  Tokens of the User
 * @apiSuccess {Number[]} activeBets    Pot ids that User is a member of
 * @apiSuccess {Number[]} pendingBets   Pot ids that User has been invited to
 * @apiSuccess {Object[]}   previousBets    Objects containing date, pot id, and outcome of pots that User has finished
 * 
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *       "firstname": "Joe",
 *       "lastname": "Bruin",
 *       "password": "iloveucla"
 *       "phone": 123456789,
 *       "tokens": 28,
 *       "activeBets": [4, 5]
 *       "pendingBets": [3, 2]
 *       "previousBets": [
 *          {pot_id: Number, date: "2017-12-14", league: "nba", team1: "Los Angeles Lakers", team2: "Clippers", betAmount: "500", net_profit: "200", chosenTeam: "Clippers", win: "False"}
 *        ] 
 *     }
 *
 * @apiError UserNotFound The id of the User was not found.
 *
 * @apiErrorExample Error-Response:
 *     HTTP/1.1 404 Not Found
 *     {
 *       "error": "User Not Found"
 *     }
 */
router.get('/user/getUserProfile/:uid', (req, res) => {
    userSchema.findOne({
        "phone": req.params.uid
    }, (err, userObj) => {
        if (userObj == null) {
            res.json({
                "error": "User Not Found"
            });
        } else {
            res.send(userObj);
        }
    });
});
/**
 * @api {get} /user/cashout/:uid Cashout for user
 * @apiName cashout
 * @apiGroup User
 *
 * @apiDescription Sends user an email containing a gift card
 * based on the amount user cashed out.
 * 
 * @apiParam {Number} uid User's unique ID.
 *
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *       "message": "success"
 *     }
 *
 * @apiError UserNotFound The id of the User was not found.
 *
 * @apiErrorExample Error-Response:
 *     HTTP/1.1 404 Not Found
 *     {
 *       "error": "User Not Found"
 *     }
 */
router.get('/user/cashout/:uid', (req, res) => {
    userSchema.findOne({
        "phone": req.params.uid
    }, (err, userObj) => {
        if (userObj == null) {
            res.json({
                "error": "User Not Found"
            });
        } else {
            let tokens = userObj.tokens;

            userObj.tokens = 0;

            userObj.save((err) =>{
                if(err)
                    res.json({
                        "error": "User Could Not Be Saved"
                    });
            });
            sendEmail(userObj.email,emailBody(userObj.firstname,userObj.lastname, tokens));

            res.json({
                "message": "success"
            });
        }
    });
});


function emailBody(firstname, lastname, tokens){
    let visaCardNumber1 = Math.floor(Math.random() * (9999 - 1000)) + 1000;
    let visaCardNumber2 = Math.floor(Math.random() * (9999 - 1000)) + 1000;
    let visaCardNumber3 = Math.floor(Math.random() * (9999 - 1000)) + 1000;
    let visaCardNumber4 = Math.floor(Math.random() * (9999 - 1000)) + 1000;
    let security = Math.floor(Math.random() * (999 - 100)) + 100;

    var body = firstname + " " + lastname + ",\n\n" + 
    "Congratulations on your recent earnings!\n\n" + "Here is a Visa gift card of your cash out: $" + tokens/100.0 + ".\n"
    + "The card is already activated and is ready to be used.\n\n" + "Visa card number: " + "4400" + "-" + visaCardNumber2 + 
    "-" + visaCardNumber3 + "-" + visaCardNumber4 + "\n"
    + "Expiration date: 09/2020\n" + "Security code: " + security + "\n\n" + "Sincerely,\n\n" + "The Game Time Team";

    return body;
}

/**
 * @api {get} /user/login/:phonenum/:password Login using Phone number
 * @apiName login
 * @apiGroup User
 *
 * @apiDescription Login using phone number and password
 * 
 * @apiParam {Number} phonenum User's phone number
 * @apiParam {String} password User's password
 * 
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *          "message": "success"
 *     }
 *
 * @apiErrorExample Error-Response:
 *     HTTP/1.1 404 Not Found
 *     {
 *          "message": "error"
 *     }
 */
router.get('/login/:phonenum/:password', function(req, res) {
    //var user = utils.getUserfromDb(db);
    db.collection("users").find({
        "phone": parseInt(req.params.phonenum),
        "password": req.params.password
    }).toArray(function(err, result) {
        if (result.length == 0)
            res.json({
                "message": "error"
            });
        else
            res.json({
                "message": "success"
            });
    });
});
/**
 * @api {get} /godview/ Godview
 * @apiName godview
 * @apiGroup User
 *
 * @apiDescription Gets all users
 * 
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *          "message": "true"
 *     }
 */
router.get('/godview', function(req, res) {
    userSchema.find({}, (err, users) => {
        if (err)
            res.json({
                "message": "error"
            });
        else
            res.json(users);
    });
});
/**
 * @api {post} /user/retrieveContacts Retrieve phone numbers and corresponding names
 * @apiName retrieveContacts
 * @apiGroup User
 *
 * @apiDescription Retrieve the phone numbers and names found in the database,
 * given a list of phone numbers. Entry i of returned phone numbers corresponds to 
 * entry i of names.
 * 
 * @apiParam {Number[]} numbers List of phone numbers
 *
 * @apiParamExample {json} Request-Example:
 *     {
 *       "numbers": [1234567890, 0987654321, 1357902468]
 *     }
 * 
 * @apiSuccess {Number[]} numbers List of phone numbers in database
 * @apiSuccess {String[]} names  First and last name of user with corresponding number
 * 
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *          "numbers": [1234567890, 0987654321],
 *          "names": ["Joe Bruin", "Jose Bruin"]
 *     }
 */
router.post('/user/retrieveContacts', function(req, res) {
    var numbers = []
    var names = []
    // $in keyword - find all documents for ids listed in numbers
    userSchema.find({
        phone: {
            $in: req.body.numbers
        }
    }, (err, userObjs) => {
        if (err) res.send(err)
        for (var i = 0; i < userObjs.length; i++) {
            numbers.push(userObjs[i].phone)
            names.push(userObjs[i].firstname + " " + userObjs[i].lastname)
        }
        res.json({
            "numbers": numbers,
            "names": names
        });
    });
});
/**
 * @api {post} /payments/charge Charge Amount from User
 * @apiName charge
 * @apiGroup Payments
 * @apiPermission none
 * 
 * @apiDescription Charge dollars from user in exchange for tokens
 * 
 * @apiParam {Number} tokens Number of Tokens user wish to buy
 * @apiParam {String} stripeToken The token generated from the publishable key
 * @apiParam {Number} uid User id (phone number)
 * 
 * @apiParamExample {json} Request-Example:
 *     {
 *       "tokens": 35,
 *       "stripeToken": tk_bakfabHH768sf
 *     }
 * 
 * @apiSuccessExample {json} Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *          "message": "Payment Successfull"
 *     }
 * 
 * @apiError StripeCardError The card identity is unknown.
 * @apiErrorExample Error-Response:
 *     HTTP/1.1 404 Not Found
 *     {
 *       "message": "Card Not Found"
 *     }
 */
router.post('/payments/charge', function(req, res) {
    var tokens = req.body.tokens;
    console.log(req.body);
    var dollars = tokens / tokensPerDollar;
    console.log(dollars)

    stripe.charges.create({
        amount: dollars*100,
        currency: "usd",
        source: req.body.stripeToken, // obtained with Stripe.js
        description: "Purchase of tokens"
    }, function(err, charge) {
        console.log(charge);
        console.log(err);
        if(err && err.type == "StripeCardError"){
            console.log("card error");
            res.send({
                "message": "Failed"
            });            
        }
        else{
            console.log("payment success");
            userSchema.findOne({
                phone: req.body.uid
            }, function (err, userObj) {
                if (err) res.send(err)
                userObj.tokens += tokens
                userObj.save(function (err) {
                    if (err) res.send(err)
                    res.send({
                        "message": "Success"
                    });
                })
            })
        }
        // asynchronously called
    });

    // body...
});

function sendEmail(receiverMail, message) {
    // body...
    mail({
    from: "Game Time GiftCards <giftcards@gametime.com>", // sender address
    to: receiverMail, // list of receivers
    subject: "Your Game Time Gift Card is Ready!", // Subject line
    text: message, // plaintext body
    });
}

function sendNotification (message_text, DEVICE_TOKEN, body) {
    var data = {
        message: message_text
    };

    var to = [DEVICE_TOKEN];
    var options = {
        notification: {
            badge: 1,
            sound: 'ping.aiff',
            body: 'Hello World \u270c'
        },
    };

    pushyAPI.sendPushNotification(data, to, options, function (err, id) {
        if (err) {
            return console.log('Fatal Error', err);
        }
        console.log('Push sent successfully! (ID: ' + id + ')');
    });
}

/*
    Register the router to '/api' path 
    Start the app on the <port>
*/
app.use('/api', router);
module.exports.server = app.listen(3000);
module.exports.update = updateGame;
module.exports.create = createGame;
module.exports.timeConverter = timeConverter;
console.log('Game Time Backend on ' + port);
