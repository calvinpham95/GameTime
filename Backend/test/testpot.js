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

describe('Pot Database Tests', function() {
    var server = serverstuff.server;
    describe('api calls', function() {
        it("/getPot should not return pot because it doesnt exist", function (done) {
            potSchema.remove({}, (err) => {
                chai.request(server)
                .get('/api/pot/getPot/1')
                .end((err, res) => {
                    res.should.have.status(200);
                    expect(res.body.message).to.equal('Pot Not Found');
                    done();
                });   
            });
        });
        it("/getPot should return pot", function (done) {
            var mockPot = factories.newPot();
            var potObj = new potSchema(mockPot);
            potSchema.remove({}, (err) => {
                potObj.save((err) => {
                     chai.request(server)
                    .get('/api/pot/getPot/1')
                    .end((err, res) => {
                        res.should.have.status(200);
                        expect(res.body.league).to.equal(potObj.league);
                        expect(res.body.pot).to.equal(potObj.pot);
                        expect(res.body.minBet).to.equal(potObj.minBet);
                        expect(res.body.winningTeam).to.equal(potObj.winningTeam);
                        expect(res.body.status).to.equal(potObj.status);
                        done();
                    });   

                });
            });       
        });
        it("/createPot should not happen because there are no accepted participants", function (done) {
            var mockPot = factories.newPot();
            var potObj = new potSchema(mockPot);
            potSchema.remove({}, (err) => {
            chai.request(server)
                .post('/api/pot/createPot')
                .send(mockPot)
                .end((err, res) => {
                    res.should.have.status(200);
                    res.body.error.should.equal("There can only be one accepted better when creating the pot")
                    done();
                });     
            });       
        });
        it ("/createPot should create a new pot and added invites", function (done) {
            var mockPot = factories.newPotWithInvites();
            var potObj = new potSchema(mockPot);
            var userObj1 = new userSchema(factories.newUser1());
            var userObj2 = new userSchema(factories.newUser2());
            var userObj3 = new userSchema(factories.newUser3());

           userSchema.remove({}, (err) => {
                potSchema.remove({}, (err) => {
                    userObj1.save((err) => {
                        userObj2.save((err) => {
                            userObj3.save((err) => {
                                chai.request(server)
                                    .post('/api/pot/createPot')
                                    .send(mockPot)
                                    .end((err, res) => {
                                        expect(res.status).to.equal(200);
                                        expect(res.body.message).to.equal('A new pot has been successfully created')
                                        potSchema.findOne({id: mockPot.id}, (err, potObj) => {
                                            expect(potObj.id).to.equal(1);
                                            expect(potObj.acceptedParticipants.length).to.equal(1);
                                            expect(potObj.pendingParticipants.length).to.equal(1);
                                            expect(potObj.teams.length).to.equal(2);
                                            expect(potObj.pot).to.equal(1);
                                            expect(potObj.minBet).to.equal(1);
                                            expect(potObj.winningTeam).to.equal(null);
                                            expect(potObj.status).to.equal('PRELIM');
                                        });
                                        userSchema.findOne({phone: userObj1.phone}, (err, userObj) => {
                                            expect(userObj.activeBets.length).to.equal(1);
                                            expect(userObj.activeBets[0]).to.equal(1);
                                            expect(userObj.pendingBets.length).to.equal(0);
                                        });
                                        userSchema.findOne({ phone: userObj2.phone }, (err, userObj) => {
                                            expect(userObj.activeBets.length).to.equal(0);
                                            expect(userObj.pendingBets.length).to.equal(1);
                                            expect(userObj.pendingBets[0]).to.equal(1);
                                        });
                                        userSchema.findOne({ phone: userObj3.phone }, (err, userObj) => {
                                            expect(userObj.activeBets.length).to.equal(0);
                                            expect(userObj.pendingBets.length).to.equal(1);
                                            expect(userObj.pendingBets[0]).to.equal(1);
                                        });
                                        done();
                                    });
                            });
                        });
                    });
                }); 
            });
        });

        it("/pot/potStatusUponGameStartSimple should change status of pots once it is called", function (done) {
            var mockPot = factories.newPot();
            var potObj = new potSchema(mockPot);
            potSchema.remove({}, (err) => {
                potObj.save((err) => {
                    chai.request(server)
                    .post('/api/pot/potStatusUponGameStartSimple')
                    .send({"pid": potObj.id})
                    .end((err, res) => {
                        res.should.have.status(200);
                        res.body.message.should.equal("game starting... pot status has been successfully updated")
                        potSchema.findOne({}, (err, pot) => {
                            expect(pot.status).equal("IN-PROGRESS");
                            done();
                        });
                    }); 
                })
            });       
        });

    });
});