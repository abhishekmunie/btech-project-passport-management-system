// Generated by CoffeeScript 1.7.1
var Application, EntityName, PGConnect, addApplication, attr, attr_list, attr_maps, citizen, expandValueUsingMap, getAllForEmail, getApplicationsWithProfileForId, getForId, globals, key, map, value;

globals = require('../globals');

PGConnect = globals.PGConnect;

EntityName = '"passport"."PassportApplication"';

citizen = require('../user/citizen');

Application = (function() {
  function Application(source, data) {
    var req, row;
    switch (source) {
      case 'db':
        row = data;
        this.Id = row.Id;
        this.CitizenEmail = row.CitizenEmail;
        this.ApplyingFor = row.ApplyingFor;
        this.ApplicationType = row.ApplicationType;
        this.PassportType = row.PassportType;
        this.PassportBookletType = row.PassportBookletType;
        this.ValidityRequired = row.ValidityRequired;
        this.GrantingOfficerEmail = row.GrantingOfficerEmail;
        this.RegionId = row.RegionId;
        break;
      case 'req':
        req = data;
        this.CitizenEmail = req.session.user.email;
        this.ApplyingFor = req.param('ApplyingFor');
        this.ApplicationType = req.param('ApplicationType');
        this.PassportType = req.param('PassportType');
        this.PassportBookletType = req.param('PassportBookletType');
        this.ValidityRequired = req.param('ValidityRequired');
        this.GrantingOfficerEmail = req.param('GrantingOfficerEmail');
        this.RegionId = req.param('RegionId');
    }
  }

  Application.prototype.insertQuery = function(client, done, callback) {
    return client.query({
      name: "application_insert",
      text: ("INSERT INTO " + EntityName + " ") + '("CitizenEmail" , "ApplyingFor" , "ApplicationType" , "PassportType" , "PassportBookletType" , "ValidityRequired" , "GrantingOfficerEmail" , "RegionId") ' + 'VALUES ( $1::varchar , $2::char , $3::char , $4::char , $5::char , $6::char , $7::varchar , $8::int ) ',
      values: [this.CitizenEmail, this.ApplyingFor, this.ApplicationType, this.PassportType, this.PassportBookletType, this.ValidityRequired, this.GrantingOfficerEmail, this.RegionId]
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

  Application.prototype.insertIntoDatabase = function(client, callback) {
    if (typeof client === "function") {
      callback = client;
      client = void 0;
      if (client != null) {
        return this.insertQuery(client, null, callback);
      } else {
        return PGConnect((function(_this) {
          return function(err, client, done) {
            if (err) {
              if (typeof done === "function") {
                done(client);
              }
              if (typeof callback === "function") {
                callback(err);
              }
              return;
            }
            return _this.insertQuery(client, done, callback);
          };
        })(this));
      }
    }
  };

  return Application;

})();

addApplication = function(application, client, callback) {
  return application.insertIntoDatabase(client, callback);
};

attr_maps = {
  PassportType: {
    'n': 'Normal',
    'd': 'Diplomatic'
  },
  ApplyingFor: {
    'f': 'Fresh Passport',
    'r': 'Re-issue of Passport'
  },
  ApplicationType: {
    'n': 'Normal',
    't': 'Tatkaal'
  },
  PassportBookletType: {
    'a': '36 Pages',
    'b': '60 Pages'
  },
  ValidityRequired: {
    'a': '10 years',
    'b': 'Up to age 18',
    'n': 'Not Applicable'
  }
};

attr_list = {};

for (attr in attr_maps) {
  map = attr_maps[attr];
  attr_list[attr] = [];
  for (key in map) {
    value = map[key];
    attr_list[attr].push({
      key: key,
      value: value
    });
  }
}

expandValueUsingMap = function(hash) {
  for (attr in attr_maps) {
    map = attr_maps[attr];
    hash[attr] = map[hash[attr]];
  }
  return hash;
};

getAllForEmail = function(CitizenEmail, callback) {
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
      name: "get_application_for_email",
      text: "SELECT * FROM " + EntityName + " WHERE \"CitizenEmail\" = $1::varchar",
      values: [CitizenEmail]
    }, function(err, result) {
      var row;
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
      if (result.rows) {
        return typeof callback === "function" ? callback(null, (function() {
          var _i, _len, _ref, _results;
          _ref = result.rows;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            row = _ref[_i];
            _results.push(new Application('db', row));
          }
          return _results;
        })()) : void 0;
      } else {
        return typeof callback === "function" ? callback(null, null) : void 0;
      }
    });
  });
};

getForId = function(Id, callback) {
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
      name: "get_application_for_id",
      text: "SELECT * FROM " + EntityName + " WHERE \"Id\" = $1::varchar",
      values: [Id]
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
      if (result.rows[0]) {
        return typeof callback === "function" ? callback(null, new Application('db', result.rows[0])) : void 0;
      } else {
        return typeof callback === "function" ? callback(null, null) : void 0;
      }
    });
  });
};

getApplicationsWithProfileForId = function(Id, callback) {
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
      name: "get_application_with_profile_for_id",
      text: "SELECT * FROM " + EntityName + " a , " + citizen.EntityName + " c WHERE c.\"email\" = a.\"CitizenEmail\" AND a.\"Id\" = $1::int ",
      values: [Id]
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
      if (result.rows[0]) {
        return typeof callback === "function" ? callback(null, result.rows[0]) : void 0;
      } else {
        return typeof callback === "function" ? callback(null, null) : void 0;
      }
    });
  });
};

module.exports = {
  Application: Application,
  EntityName: EntityName,
  attr_maps: attr_maps,
  attr_list: attr_list,
  expandValueUsingMap: expandValueUsingMap,
  addApplication: addApplication,
  getAllForEmail: getAllForEmail,
  getForId: getForId,
  getApplicationsWithProfileForId: getApplicationsWithProfileForId
};
