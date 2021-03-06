// Generated by CoffeeScript 1.7.1
var admin, user, verifyCredentials;

user = require('./user');

admin = require('./admin');

verifyCredentials = function(email, password, callback) {
  user.verifyCredentials(email, password, function(err, validity) {
    if (err) {
      return typeof callback === "function" ? callback(err) : void 0;
    }
    if (validity === true) {
      return typeof callback === "function" ? callback(null, true) : void 0;
    } else {
      admin.verifyCredentials(email, password, function(err, validity) {
        if (err) {
          return typeof callback === "function" ? callback(err) : void 0;
        }
        if (typeof callback === "function") {
          callback(null, validity);
        }
      });
    }
  });
};

module.exports = {
  verifyCredentials: verifyCredentials
};
