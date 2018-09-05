var mongoose = require('mongoose');
var assert = require('assert');

const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

module.exports = {
    dbConfig:  {
        "dburl": 'mongodb://localhost:27017/test',
        "tableName": "user",
        "key": "123",
        "checkAuth": false,
        "db": ""
    },
    createCollection: function(config) {
        checkSecretKey(config);
    },

    checkSecretKey: function(config) {
        if (!config.checkAuth)
            return true;
        var auth = false;
        rl.question('Enter the secret key to perform operations', (answer) => {
            console.log(answer);
            if (answer == config.key) {
                auth = true;
            }
            rl.close();
        });
        return auth;
    }
}
//connectDB(dbConfig);
//createCollection(dbConfig);
