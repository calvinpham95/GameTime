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

describe('User Database Tests', function() {
	  var server;
	  beforeEach(function (done) {
	    server = serverstuff.server;
	    userSchema.remove({}, (err) => { 
            done();       
        }); 
	  });

	  afterEach((done) => {
	  	server.close();
	  	done();
	  });

	describe('register new user', function() {
		it("should create user 1", function (done) {
            var mockUser = factories.newUser1();
            chai.request(server)
            	.post('/api/user/registerUser')
            	.send(mockUser)
            	.end((err, res) => {
            		res.should.have.status(200);
 					res.body.message.should.equal('Success! User Created. Verification code sent.'); 
            		done();
            	});
        });
        it("should create user 2", function (done) {
            var mockUser = factories.newUser2();
            chai.request(server)
                .post('/api/user/registerUser')
                .send(mockUser)
                .end((err, res) => {
                    res.should.have.status(200);
                    res.body.message.should.equal('Success! User Created. Verification code sent.');
                    done();
                });
        });
        it("should create user 3", function (done) {
            var mockUser = factories.newUser3();
            chai.request(server)
                .post('/api/user/registerUser')
                .send(mockUser)
                .end((err, res) => {
                    res.should.have.status(200);
                    res.body.message.should.equal('Success! User Created. Verification code sent.');
                    done();
                });
        });
		it("should fail to create new user because already present", function (done) {
			var mockUser = factories.newUser1();
            var userObj = new userSchema(mockUser);
            userObj.save((err) => {});
            chai.request(server)
            	.post('/api/user/registerUser')
            	.send(mockUser)
            	.end((err, res) => {
            		res.should.have.status(200);
 					res.body.message.should.equal('User already present');
            		done();
            	});
        });
	});

	describe('retrieve a user', function() {
		it("should return a user", function (done) {
			var mockUser = factories.newUser1();
            var userObj = new userSchema(mockUser);
            userObj.save((err) => {
                chai.request(server)
                .get('/api/user/getUserProfile/8189550123')
                .end((err, res) => {
                    res.should.have.status(200);
                    res.body.firstname.should.equal(mockUser.firstname);
                    res.body.lastname.should.equal(mockUser.lastname);
                    res.body.email.should.equal(mockUser.email);
                    res.body.phone.should.equal(mockUser.phone);
                    res.body.tokens.should.equal(500);
                    res.body.password.should.equal(mockUser.password);
                    expect(res.body.activeBets.length).to.equal(0);
                    expect(res.body.pendingBets.length).to.equal(0);
                    expect(res.body.previousBets.length).to.equal(0);
                    done();
                });
            });
         
        });

		it("shoud not return a user because not found", function (done) {
            chai.request(server)
            	.get('/api/user/getUserProfile/8182979939')
            	.end((err, res) => {
            		res.should.have.status(200);
            		res.body.error.should.equal('User Not Found');
            		done();
            	});
        });

        it("god view should return all users", function (done) {
            var userObj1 = new userSchema(factories.newUser1());
            var userObj2 = new userSchema(factories.newUser2());
            var userObj3 = new userSchema(factories.newUser3());

            userSchema.remove({}, (err) => { 
                userObj1.save((err) => {
                    userObj2.save((err) => {
                        userObj3.save((err) => { 
                            chai.request(server)
                            .get('/api/godview')
                            .end((err,res) => {
                                res.should.have.status(200);
                                res.body.length.should.equal(3);
                                done();
                            })
                        });
                    });
                });
            });
        });

        it("/login/:phonenum/:password should return success with proper credentials", function (done) {
            var userObj1 = new userSchema(factories.newUser1());
            userSchema.remove({}, (err) => { 
                userObj1.save((err) => {
                    chai.request(server)
                    .get('/api/login/' + userObj1.phone + '/' + userObj1.password + '/')
                    .end((err,res) => {
                        res.should.have.status(200);
                        res.body.message.should.equal("success");
                        done();
                    });  
                });
            });
        });

        it("/login/:phonenum/:password should return error with improper credentials", function (done) {
            var userObj1 = new userSchema(factories.newUser1());
            userSchema.remove({}, (err) => { 
                userObj1.save((err) => {
                    chai.request(server)
                    .get('/api/login/' + userObj1.phone + '/' +  + '123/')
                    .end((err,res) => {
                        res.should.have.status(200);
                        res.body.message.should.equal("error");
                        done();
                    });  
                });
            });
        });

        it("/godview/user/retrieveContacts should return names and numbers that are within database", function (done) {
            var userObj1 = new userSchema(factories.newUser1());
            var userObj2 = new userSchema(factories.newUser2());
            var userObj3 = new userSchema(factories.newUser3());

            userSchema.remove({}, (err) => { 
                userObj1.save((err) => {
                    userObj2.save((err) => {
                        userObj3.save((err) => {
                            chai.request(server)
                            .post('/api/user/retrieveContacts')
                            .send({"numbers": [userObj1.phone, userObj2.phone]})
                            .end((err,res) => {
                                res.should.have.status(200);
                                res.body.numbers[0].should.equal(userObj1.phone);
                                res.body.numbers[1].should.equal(userObj2.phone);
                                res.body.names[0].should.equal(userObj1.firstname + " " + userObj1.lastname);
                                res.body.names[1].should.equal(userObj2.firstname + " " + userObj2.lastname);  
                                done();                              
                            })
                        })
                    })
                });
            });
        });

        it("/godview/user/retrieveContacts should return names and numbers that are within database", function (done) {
            var userObj1 = new userSchema(factories.newUser1());
            var userObj2 = new userSchema(factories.newUser2());
            var userObj3 = new userSchema(factories.newUser3());

            userSchema.remove({}, (err) => { 
                userObj1.save((err) => {
                    userObj2.save((err) => {
                        userObj3.save((err) => {
                            chai.request(server)
                            .post('/api/user/retrieveContacts')
                            .send({"numbers": []})
                            .end((err,res) => {
                                res.should.have.status(200);
                                res.body.numbers.length.should.equal(0);
                                res.body.names.length.should.equal(0);
                                done();                              
                            })
                        })
                    })
                });
            });
        });

        it("/user/resendVerification should return user not found since user does not exist", function (done) {
            var userObj1 = new userSchema(factories.newUser1());

            userSchema.remove({}, (err) => { 
                chai.request(server)
                .post('/api/user/resendVerification')
                .send({"phone": userObj1.phone})
                .end((err,res) => {
                    res.should.have.status(200);
                    res.body.error.should.equal("User Not Found");
                    done();                              
                })
            });
        });

        it("/user/resendVerification should return User has already been verified user already verified", function (done) {
            var userObj1 = new userSchema(factories.newUser1());

            userSchema.remove({}, (err) => { 
                userObj1.save((err) => {
                    chai.request(server)
                    .post('/api/user/resendVerification')
                    .send({"phone": userObj1.phone})
                    .end((err,res) => {
                        res.should.have.status(200);
                        res.body.error.should.equal("User has already been verified");
                        done();                              
                    })
                });
            });
        });

        it("/user/checkVerified should return User Not Found", function (done) {
        var userObj1 = new userSchema(factories.newUser1());
        userObj1.verification = 0;

        userSchema.remove({}, (err) => { 
                chai.request(server)
                .post('/api/user/checkVerified')
                .send({"phone": userObj1.phone, "code": userObj1.verification})
                .end((err,res) => {
                    res.should.have.status(200);
                    res.body.error.should.equal("User Not Found");
                    done();                              
                })
            });
        });

        it("/user/checkVerified should return User is already verified", function (done) {
            var userObj1 = new userSchema(factories.newUser1());
    
            userSchema.remove({}, (err) => { 
                    userObj1.save((err) => {
                        chai.request(server)
                        .post('/api/user/checkVerified')
                        .send({"phone": userObj1.phone, "code": userObj1.verification})
                        .end((err,res) => {
                            res.should.have.status(200);
                            res.body.error.should.equal('User is already verified');
                            done();                              
                        })
                    })
                });
            });

        it("/user/checkVerified should return User is not verified", function (done) {
            var userObj1 = new userSchema(factories.newUser1());
            userObj1.verification = 0;

            userSchema.remove({}, (err) => { 
                    userObj1.save((err) => {
                        chai.request(server)
                        .post('/api/user/checkVerified')
                        .send({"phone": userObj1.phone})
                        .end((err,res) => {
                            res.should.have.status(200);
                            res.body.message.should.equal('User is not verified');
                            done();                              
                        })
                    })
                });
            });

        it("/user/checkVerified should return Success! User is now verified'", function (done) {
            var userObj1 = new userSchema(factories.newUser1());
            userObj1.verification = 0;

            userSchema.remove({}, (err) => { 
                    userObj1.save((err) => {
                        chai.request(server)
                        .post('/api/user/checkVerified')
                        .send({"phone": userObj1.phone, "code": userObj1.verification})
                        .end((err,res) => {
                            res.should.have.status(200);
                            res.body.message.should.equal('Success! User is now verified');
                            done();                              
                        })
                    })
                });
            });

        it("/user/checkVerified should return Wrong verification code", function (done) {
            var userObj1 = new userSchema(factories.newUser1());
            userObj1.verification = 0;

            userSchema.remove({}, (err) => { 
                    userObj1.save((err) => {
                        chai.request(server)
                        .post('/api/user/checkVerified')
                        .send({"phone": userObj1.phone, "code": 10})
                        .end((err,res) => {
                            res.should.have.status(200);
                            res.body.error.should.equal('Wrong verification code');
                            done();                              
                        })
                    })
                });
            });
	});

});