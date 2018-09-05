"use strict";

const mongoose = require('mongoose');
const chai = require('chai');
const chaiHttp = require('chai-http');
const expect = chai.expect;
const schemas = require('../model/schema');
const should = chai.should();
const userSchema = schemas.userModel;
const factories = require('./factories');
const serverstuff = require('../server');
const gameSchema = schemas.gameModel;
const potSchema = schemas.potModel;
const async = require('async');

chai.use(chaiHttp);

describe('Game Database Tests', function() {
    var server = serverstuff.server;

    describe('helper functions', function() {
        it("should update a game object", function (done) {
            var mockGame = factories.newGame();
            var gameObj = new gameSchema(mockGame);
            gameSchema.remove({}, (err) => {
                
                gameObj.save((err) => {
                    serverstuff.update(1,1,"3",'In Progress');

                    gameSchema.find({}, (err,games) => {
                        expect(games[0].team1Score).to.equal(1);
                        expect(games[0].team2Score).to.equal(1);
                        expect(games[0].status).to.equal(gameObj.schema.path('status').enumValues[1]);
                        done();
                    });
                });           
            }); 
        });

        it("should not update a game object with undefined data", function (done) {
            var mockGame = factories.newGame();
            var gameObj = new gameSchema(mockGame);
            gameSchema.remove({}, (err) => {
                
                gameObj.save((err) => {
                     serverstuff.update(undefined,undefined,"3",'In Progress');

                     gameSchema.find({}, (err,games) => {
                        expect(games[0].team1Score).to.equal(0);
                        expect(games[0].team2Score).to.equal(0);
                        expect(games[0].status).to.equal(gameObj.schema.path('status').enumValues[0]);
                        done();
                    });
                });           
            }); 
        });

        it("should create a game", function (done) {
            var mockGame = factories.newGame();
            var gameObj = new gameSchema(mockGame);
            gameSchema.remove({}, (err) => {
                serverstuff.create(mockGame.startDate, mockGame.team1,mockGame.team2,mockGame.id,mockGame.startTime, mockGame.type, () =>{
                    gameSchema.find({}, (err,games) => {
                        expect(games.length).to.equal(1);
                        expect(games[0].team1Score).to.equal(mockGame.team1Score);
                        expect(games[0].team2Score).to.equal(mockGame.team2Score);
                        expect(games[0].startDate).to.equal(mockGame.startDate);
                        expect(games[0].team1).to.equal(mockGame.team1);
                        expect(games[0].team2).to.equal(mockGame.team2);
                        expect(games[0].id).to.equal(mockGame.id);
                        expect(games[0].startTime).to.equal(mockGame.startTime);
                        expect(games[0].status).to.equal(gameObj.schema.path('status').enumValues[0]);
                        done();
                    });   
                });       
            }); 
        });

    });

    describe('api calls', function() {
        it("/getGame should return the game with the proper id", function (done) {
            var mockGame = factories.newGame();
            var gameObj = new gameSchema(mockGame);
            gameSchema.remove({}, (err) => {
                 gameObj.save((err) => {
                    chai.request(server)
                    .get('/api/game/getGame/3')
                    .end((err, res) => {
                        res.should.have.status(200);
                        expect(res.body.team1Score).to.equal(mockGame.team1Score);
                        expect(res.body.team2Score).to.equal(mockGame.team2Score);
                        expect(res.body.startDate).to.equal(mockGame.startDate);
                        expect(res.body.team1).to.equal(mockGame.team1);
                        expect(res.body.team2).to.equal(mockGame.team2);
                        expect(res.body.id).to.equal(mockGame.id);
                        expect(res.body.startTime).to.equal(mockGame.startTime);
                        expect(res.body.status).to.equal('Not Begin');
                        done();
                    });
                });
            });
        });

         it("/getGame shoud return game not found if id doesnt exist", function (done) {
            var mockGame = factories.newGame();
            var gameObj = new gameSchema(mockGame);
            gameSchema.remove({}, (err) => {
                chai.request(server)
                .get('/api/game/getGame/1')
                .end((err, res) => {
                    res.should.have.status(200);
                    expect(res.body.message).to.equal('Game Not Found');
                    done();
                });
            });
        });

        it("/getSevenDayNBAGames should return games not found because none exist", function (done) {
            gameSchema.remove({}, (err) => {
                chai.request(server)
                .get('/api/game/getSevenDayNBAGames')
                .end((err, res) => {
                    res.should.have.status(200);
                    expect(res.body.message).to.equal('Games Not Found');
                    done();
                });
            });
        });

        it("/getSevenDayNFLGames should return games not found because none exist", function (done) {
            gameSchema.remove({}, (err) => {
                chai.request(server)
                .get('/api/game/getSevenDayNFLGames')
                .end((err, res) => {
                    res.should.have.status(200);
                    expect(res.body.message).to.equal('Games Not Found');
                    done();
                });
            });
        });


        it("/getSevenDayNHLGames should return games not found because none exist", function (done) {
            gameSchema.remove({}, (err) => {
                chai.request(server)
                .get('/api/game/getSevenDayNHLGames')
                .end((err, res) => {
                    res.should.have.status(200);
                    expect(res.body.message).to.equal('Games Not Found');
                    done();
                });
            });
        });

        it("/getSevenDayPremierGames should return games not found because none exist", function (done) {
            gameSchema.remove({}, (err) => {
                chai.request(server)
                .get('/api/game/getSevenDayPremierGames')
                .end((err, res) => {
                    res.should.have.status(200);
                    expect(res.body.message).to.equal('Games Not Found');
                    done();
                });
            });
        });

        it("/getSevenDayNBAGames should return seven games", function (done) {
            gameSchema.remove({}, (err) => {
                var games = factories.sevenNBAGames();
                async.each(games, function(game, callback) {
                    var gameObj = new gameSchema(game);
                    gameObj.save((err) => {callback()})
                }, () => {
                    chai.request(server)
                    .get('/api/game/getSevenDayNBAGames')
                    .end((err, res) => {
                        res.should.have.status(200);
                        expect(res.body.length).to.equal(7);
                        done();
                    });
                });

            });
        });


        it("/getSevenDayNHLGames should return seven games", function (done) {
            gameSchema.remove({}, (err) => {
                var games = factories.sevenNHLGames();
                async.each(games, function(game, callback) {
                    var gameObj = new gameSchema(game);
                    gameObj.save((err) => {callback()})
                }, () => {
                    chai.request(server)
                    .get('/api/game/getSevenDayNHLGames')
                    .end((err, res) => {
                        res.should.have.status(200);
                        expect(res.body.length).to.equal(7);
                        done();
                    });
                });

            });
        });


        it("/getSevenDayNFLGames should return seven games", function (done) {
            gameSchema.remove({}, (err) => {
                var games = factories.sevenNFLGames();
                async.each(games, function(game, callback) {
                    var gameObj = new gameSchema(game);
                    gameObj.save((err) => {callback()})
                }, () => {
                    chai.request(server)
                    .get('/api/game/getSevenDayNFLGames')
                    .end((err, res) => {
                        res.should.have.status(200);
                        expect(res.body.length).to.equal(7);
                        done();
                    });
                });

            });
        });

        it("/getSevenDayPremierGames should return seven games", function (done) {
            gameSchema.remove({}, (err) => {
                var games = factories.sevenPRMGames();
                async.each(games, function(game, callback) {
                    var gameObj = new gameSchema(game);
                    gameObj.save((err) => {callback()})
                }, () => {
                    chai.request(server)
                    .get('/api/game/getSevenDayPremierGames')
                    .end((err, res) => {
                        res.should.have.status(200);
                        expect(res.body.length).to.equal(7);
                        done();
                    });
                });

            });
        });

        it("timeConverter should convert time to AM/PM", function (done) {
            expect(serverstuff.timeConverter("23:00")).to.equal("11:00PM");
            expect(serverstuff.timeConverter("10:00")).to.equal("10:00AM");
            expect(serverstuff.timeConverter("00:01")).to.equal("12:01AM");
            expect(serverstuff.timeConverter("12:00")).to.equal("12:00PM");
            expect(serverstuff.timeConverter("21:35")).to.equal("9:35PM");
            done();
        });

    });
});