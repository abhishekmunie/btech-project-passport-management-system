// Generated by CoffeeScript 1.7.1
var EntityName, PGConnect, Reset, addResetKeyForEmail, appCrypto, crypto, debug, deleteFromDatabaseResetKey, deleteQuery, emailClient, getEmailForResetKey, globals, insertIntoDatabase, insertQuery, removeResetKey, verifyResetKey;

crypto = require('crypto');

appCrypto = require('../crypto');

globals = require('../globals');

debug = globals.debug;

PGConnect = globals.PGConnect;

emailClient = require('../email');

EntityName = '"passport"."ResetKey"';

Reset = (function() {
  function Reset(email, resetKey) {
    this.email = email;
    this.resetKey = resetKey;
  }

  return Reset;

})();

insertQuery = function(values, client, done, callback) {
  return client.query({
    name: "resetKey_insert",
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

insertIntoDatabase = function(email, resetKey, client, callback) {
  if (typeof client === "function") {
    callback = client;
    client = void 0;
  }
  if (client) {
    insertQuery([resetKey, email], client, null, callback);
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
      insertQuery([resetKey, email], client, done, callback);
    });
  }
};

addResetKeyForEmail = function(email, name, client, callback) {
  if (typeof client === "function") {
    callback = client;
    client = void 0;
  }
  return crypto.randomBytes(64, function(ex, buf) {
    var resetKey;
    if (ex) {
      return typeof callback === "function" ? callback(ex) : void 0;
    }
    resetKey = buf.toString('base64');
    return insertIntoDatabase(email, resetKey, client, function(err) {
      var to;
      if (err) {
        return typeof callback === "function" ? callback(err) : void 0;
      }
      to = name ? "" + name + " <" + email + ">" : email;
      return emailClient.sendPasswordResetEMail(to, resetKey, callback);
    });
  });
};

getEmailForResetKey = function(resetKey, callback) {
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
      name: "reset_get_for_key",
      text: "SELECT email FROM " + EntityName + " WHERE \"resetKey\" = $1::varchar ",
      values: [resetKey]
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

verifyResetKey = function(email, resetKey, callback) {
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
      name: "reset_verification",
      text: "SELECT count(*) AS exists FROM " + EntityName + " WHERE \"email\" = $1::varchar AND \"resetKey\" = $2::varchar ",
      values: [email, resetKey]
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

deleteQuery = function(values, client, done, callback) {
  console.log(values);
  return client.query({
    name: "reset_delete",
    text: "DELETE FROM " + EntityName + " WHERE \"resetKey\" = $1::varchar ",
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

deleteFromDatabaseResetKey = function(resetKey, client, callback) {
  if (typeof client === "function") {
    callback = client;
    client = void 0;
  }
  if (client != null) {
    deleteQuery([resetKey], client, null, callback);
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
      deleteQuery([resetKey], client, done, callback);
    });
  }
};

removeResetKey = function(resetKey, client, callback) {
  console.log(resetKey);
  return deleteFromDatabaseResetKey(resetKey, client, callback);
};

module.exports = {
  Reset: Reset,
  EntityName: EntityName,
  addResetKeyForEmail: addResetKeyForEmail,
  getEmailForResetKey: getEmailForResetKey,
  verifyResetKey: verifyResetKey,
  removeResetKey: removeResetKey
};