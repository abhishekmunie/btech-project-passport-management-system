// Generated by CoffeeScript 1.7.1
var EntityName, PGConnect, TYPE, UnverifiedUser, addUnverifiedUser, appCrypto, crypto, debug, deleteFromDatabaseUnverifiedUserForVerificationKey, deleteQuery, emailClient, getEmailForVerificationKey, globals, insertIntoDatabase, insertQuery, removeUnverifiedUser, verifyVerificationKey;

crypto = require('crypto');

appCrypto = require('../crypto');

globals = require('../globals');

debug = globals.debug;

PGConnect = globals.PGConnect;

emailClient = require('../email');

EntityName = '"passport"."UnverifiedUser"';

TYPE = 'UnverifiedUser';

UnverifiedUser = (function() {
  function UnverifiedUser(email) {
    this.email = email;
    this.type = TYPE;
  }

  return UnverifiedUser;

})();

insertQuery = function(values, client, done, callback) {
  return client.query({
    name: "unverifieduser_insert",
    text: "INSERT INTO " + EntityName + " VALUES ( $1::varchar , $2::varchar ) ",
    values: values
  }, function(err, result) {
    if (err) {
      if (typeof done === "function") {
        done(client);
      }
      if (typeof callback === "function") {
        callback(err);
      }
      return;
    }
    if (typeof done === "function") {
      done();
    }
    return typeof callback === "function" ? callback() : void 0;
  });
};

insertIntoDatabase = function(email, verificationKey, client, callback) {
  if (typeof client === "function") {
    callback = client;
    client = void 0;
  }
  if (client != null) {
    insertQuery([email, verificationKey], client, null, callback);
  } else {
    PGConnect(function(err, client, done) {
      if (err) {
        if (typeof done === "function") {
          done(client);
        }
        if (typeof callback === "function") {
          callback(err);
        }
        return;
      }
      insertQuery([email, verificationKey], client, done, callback);
    });
  }
};

getEmailForVerificationKey = function(verificationKey, callback) {
  return PGConnect(function(err, client, done) {
    if (err) {
      if (typeof done === "function") {
        done(client);
      }
      if (typeof callback === "function") {
        callback(err);
      }
      return;
    }
    return client.query({
      name: "unverifieduser_get_for_key",
      text: "SELECT email FROM " + EntityName + " WHERE \"VerificationKey\" = $1::varchar ",
      values: [verificationKey]
    }, function(err, result) {
      if (err) {
        if (typeof done === "function") {
          done(client);
        }
        if (typeof callback === "function") {
          callback(err);
        }
        return;
      }
      if (typeof done === "function") {
        done();
      }
      return typeof callback === "function" ? callback(null, result.rows[0] ? result.rows[0].email : null) : void 0;
    });
  });
};

verifyVerificationKey = function(email, verificationKey, callback) {
  return PGConnect(function(err, client, done) {
    if (err) {
      if (typeof done === "function") {
        done(client);
      }
      if (typeof callback === "function") {
        callback(err);
      }
      return;
    }
    return client.query({
      name: "unverifieduser_verification",
      text: "SELECT count(*) AS exists FROM " + EntityName + " WHERE \"email\" = $1::varchar AND \"VerificationKey\" = $2::varchar ",
      values: [email, verificationKey]
    }, function(err, result) {
      if (err) {
        if (typeof done === "function") {
          done(client);
        }
        if (typeof callback === "function") {
          callback(err);
        }
        return;
      }
      if (typeof done === "function") {
        done();
      }
      return typeof callback === "function" ? callback(null, result.rows[0].exists === '1') : void 0;
    });
  });
};

addUnverifiedUser = function(email, name, client, callback) {
  if (typeof client === "function") {
    callback = client;
    client = void 0;
  }
  return crypto.randomBytes(64, function(ex, buf) {
    var verificationKey;
    if (ex) {
      return typeof callback === "function" ? callback(ex) : void 0;
    }
    verificationKey = buf.toString('base64');
    return insertIntoDatabase(email, verificationKey, client, function(err) {
      var to;
      if (err) {
        return typeof callback === "function" ? callback(err) : void 0;
      }
      to = name ? "" + name + " <" + email + ">" : email;
      return emailClient.sendVerificationEMail(to, verificationKey, callback);
    });
  });
};

deleteQuery = function(values, client, done, callback) {
  return client.query({
    name: "unverifieduser_delete",
    text: "DELETE FROM " + EntityName + " WHERE \"VerificationKey\" = $1::varchar ",
    values: values
  }, function(err, result) {
    if (err) {
      if (typeof done === "function") {
        done(client);
      }
      if (typeof callback === "function") {
        callback(err);
      }
      return;
    }
    if (typeof done === "function") {
      done();
    }
    return typeof callback === "function" ? callback() : void 0;
  });
};

deleteFromDatabaseUnverifiedUserForVerificationKey = function(verificationKey, client, callback) {
  if (typeof client === "function") {
    callback = client;
    client = void 0;
  }
  if (client != null) {
    deleteQuery([verificationKey], client, null, callback);
  } else {
    PGConnect(function(err, client, done) {
      if (err) {
        if (typeof done === "function") {
          done(client);
        }
        if (typeof callback === "function") {
          callback(err);
        }
        return;
      }
      deleteQuery([verificationKey], client, done, callback);
    });
  }
};

removeUnverifiedUser = function(verificationKey, client, callback) {
  return deleteFromDatabaseUnverifiedUserForVerificationKey(verificationKey, client, callback);
};

module.exports = {
  UnverifiedUser: UnverifiedUser,
  type: TYPE,
  addUnverifiedUser: addUnverifiedUser,
  removeUnverifiedUser: removeUnverifiedUser,
  getEmailForVerificationKey: getEmailForVerificationKey,
  verifyVerificationKey: verifyVerificationKey
};
