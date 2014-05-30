// Generated by CoffeeScript 1.7.1
(function() {
  var Database, Model, YAML, findFiles, fs, _;

  fs = require('fs');

  YAML = require("yamljs");

  _ = require('underscore');

  findFiles = function(dir, callback) {
    var callbackCount, done, fileList, recurse;
    fileList = [];
    callbackCount = 0;
    done = function() {
      callbackCount--;
      if (callbackCount === 0) {
        return callback(fileList);
      }
    };
    recurse = function(path) {
      callbackCount++;
      return fs.readdir(path, function(err1, files) {
        var file, _fn, _i, _len;
        _fn = function(file) {
          var f;
          f = "" + path + "/" + file;
          callbackCount++;
          return fs.stat(f, function(err2, stats) {
            if (stats.isDirectory()) {
              recurse(f);
            } else if (stats.isFile()) {
              fileList.push(f);
            }
            return done();
          });
        };
        for (_i = 0, _len = files.length; _i < _len; _i++) {
          file = files[_i];
          if (file[0] === '.') {
            continue;
          }
          _fn(file);
        }
        return done();
      });
    };
    return recurse(dir);
  };

  Database = (function() {
    function Database(path, models) {
      this.models = models;
      this.path = path;
    }

    Database.prototype.initialize = function() {};

    Database.prototype.save = function(model, data, file, callback) {
      data = YAML.stringify(data, 1000, 1);
      return fs.writeFile(file, data, {
        encoding: 'utf8'
      }, function(err) {
        return callback();
      });
    };

    Database.prototype.loadModels = function(model, callback) {
      var objs, path;
      path = "" + this.path + "/" + model;
      objs = [];
      return findFiles(path, (function(_this) {
        return function(files) {
          var file, _i, _len, _results;
          _results = [];
          for (_i = 0, _len = files.length; _i < _len; _i++) {
            file = files[_i];
            _results.push(_this.loadFile(model, file, function(obj) {
              objs.push(obj);
              if (objs.length === files.length) {
                return callback(objs);
              }
            }));
          }
          return _results;
        };
      })(this));
    };

    Database.prototype.loadFile = function(model, file, callback) {
      return fs.readFile(file, {
        encoding: 'utf8'
      }, (function(_this) {
        return function(err, data) {
          data = YAML.parse(data);
          return callback(new _this.models[model](data, {
            file: file,
            db: _this
          }));
        };
      })(this));
    };

    return Database;

  })();

  Model = (function() {
    function Model() {
      this._init.apply(this, arguments);
    }

    Model.prototype._initFuncs = [];

    Model.initialize = function(func) {
      this.prototype._initFuncs = _.clone(this.prototype._initFuncs);
      return this.prototype._initFuncs.push(func);
    };

    Model.prototype._init = function() {
      var init, _i, _len, _ref, _results;
      _ref = this._initFuncs;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        init = _ref[_i];
        _results.push(init.apply(this, arguments));
      }
      return _results;
    };

    Model.include = function(obj) {
      var k, v, _results;
      _results = [];
      for (k in obj) {
        v = obj[k];
        if (this.prototype[k] == null) {
          _results.push(this.prototype[k] = v);
        }
      }
      return _results;
    };

    Model.prototype.model = 'Model';

    Model.prototype._defaults = {};

    Model.defaults = function(defaults) {
      var k, v, _results;
      this.prototype._defaults = _.clone(this.prototype._defaults);
      _results = [];
      for (k in defaults) {
        v = defaults[k];
        _results.push(this.prototype._defaults[k] = v);
      }
      return _results;
    };

    Model.initialize(function(values, options) {
      var k, v, _ref, _results;
      if (options.file != null) {
        this.file = options.file;
      }
      this.db = options.db;
      this.values = {};
      _ref = this._defaults;
      _results = [];
      for (k in _ref) {
        v = _ref[k];
        if (values[k] != null) {
          _results.push(this.values[k] = values[k]);
        } else {
          _results.push(this.values[k] = v);
        }
      }
      return _results;
    });

    Model.prototype.toJSON = function() {
      return _.clone(this.values);
    };

    Model.prototype.get = function(key) {
      return this.values[key];
    };

    Model.prototype.set = function(obj) {
      var k, v, _results;
      _results = [];
      for (k in obj) {
        v = obj[k];
        if (k in this._defaults) {
          _results.push(this.values[k] = v);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Model.prototype.save = function(callback) {
      if (this.file == null) {
        return;
      }
      return this.db.save(this.model, this.toJSON(), this.file, callback);
    };

    return Model;

  })();

  exports.Database = Database;

  exports.Model = Model;

}).call(this);