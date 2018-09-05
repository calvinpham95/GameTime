
var express = require('express'),
    bodyParser = require('body-parser'),
    morgan = require('morgan')
/*
*Initialising app and router
*/
var publishableKey = 'pk_test_j***************'
var secretKey = 'sk_test_kqTV**********'


var app = express();
var router = express.Router();
var stripe = require('stripe')(secretKey)
app.use(morgan('dev'));
app.use(bodyParser.urlencoded({
    extended: true
}));
app.use(bodyParser.json());
var port = process.env.PORT || 3000;


/**
 * @api {post} /payments/charge Charge Amount from User
 * @apiName charge
 * @apiGroup Payments
 * @apiPermission none
 * 
 * @apiDescription Charge dollars from user in exchange for tokens
 * 
 * @apiParam {tokens} Number of Tokens user wish to buy
 * @apiParam {stripeToken} The token generated from the publishable key
 * @apiParamExample {json} Request-Example:
 *     {
 *       "tokens": 35,
 *		 "stripeToken": tk_bakfabHH768sf
 *     }
 * 
 * 
 * @apiSuccessExample {json} Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *			"message": "Payment Successfull"
 *     }
 * 
 * @apiError StripeCardError The card identity is unknown.
 * @apiErrorExample Error-Response:
 *     HTTP/1.1 404 Not Found
 *     {
 *       "message": "Card Not Found"
 *     }
 */

 
router.post('/payments/charge', function(req,res) {
	var tokensPerDollar = 10;
	var tokens = req.body.tokens ;
	//todo move the tokensPerDollar outside
	var dollars = tokens / tokensPerDollar;
	console.log(dollars)

	var charge = stripe.charges.create({
		amount : dollars,
		currency : "usd",
		source : req.body.stripeToken
	},function(err, charge){
		console.log(charge);
		if(err && err.type == "StripeCardError"){
			console.log("card error");
			//todo: update the tokens in the db
		}
		else{
			console.log("payment success");
		}

		res.send("hey");

	}); 

	// body...
});


app.use('/api', router);
app.listen(port);
console.log('Luck Backend on ' + port);