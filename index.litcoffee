Required repositories

    fs = require 'fs'
    YAML = require "yamljs"
    _ = require 'underscore'

Find files in a directory

    findFiles = (dir, callback) ->
     fileList = []

     callbackCount = 0

     done = ->
      callbackCount--
      if callbackCount is 0
       callback fileList

     recurse = (path) ->
      callbackCount++
      fs.readdir path, (err1, files) ->
       for file in files
        continue if file[0] is '.'
        do (file) ->
         f = "#{path}/#{file}"
         callbackCount++
         fs.stat f, (err2, stats) ->
          if stats.isDirectory()
           recurse f
          else if stats.isFile()
           fileList.push f
          done()

       done()

     recurse dir

## Database

    class Database
     constructor: (path, models) ->
      @models = models
      @path = path

     initialize: ->

     save: (model, data, file, callback) ->
      data = YAML.stringify data, 1000, 1
      fs.writeFile file, data, encoding: 'utf8', (err) ->
       callback()

     loadModels: (model, callback) -> #Loads all files
      path = "#{@path}/#{model}"
      objs = []

      findFiles path, (files) =>
       for file in files
        @loadFile model, file, (obj) ->
         objs.push obj
         if objs.length is files.length
          callback objs

     loadFile: (model, file, callback) ->
      fs.readFile file, encoding: 'utf8', (err, data) =>
       data = YAML.parse data
       callback new @models[model] data, file: file, db: this



## Model class
Introduces class level function initialize and include. This class is the base class of all other data models. It has `get` and `set` methods to change values. The structure of the object is defined by `defaults`.

    class Model
     constructor: ->
      @_init.apply @, arguments

     _initFuncs: []

####Register initialize functions.
All initializer funcitons in subclasses will be called with the constructor arguments.

     @initialize: (func) ->
      @::_initFuncs = _.clone @::_initFuncs
      @::_initFuncs.push func

     _init: ->
      for init in @_initFuncs
       init.apply @, arguments

####Include objects.
You can include objects by registering them with @include. This solves the problem of single inheritence.

     @include: (obj) ->
      for k, v of obj when not @::[k]?
       @::[k] = v


     model: 'Model'

     _defaults: {}

####Register default key value set.
Subclasses can add to default key-values of parent classes

     @defaults: (defaults) ->
      @::_defaults = _.clone @::_defaults
      for k, v of defaults
       @::_defaults[k] = v

Build a model with the structure of defaults. `options.db` is a reference to the `Database` object, which will be used when updating the object. `options.file` is the path of the file, which will be null if this is a new object.

     @initialize (values, options) ->
      @file = options.file if options.file?
      @db = options.db
      @values = {}
      for k, v of @_defaults
       if values[k]?
        @values[k] = values[k]
       else
        @values[k] = v

####Returns key value set

     toJSON: -> _.clone @values

####Get value of a given key

     get: (key) -> @values[key]

####Set key value combination

     set: (obj) ->
      for k, v of obj
       @values[k] = v if k of @_defaults

###Save the object

     save: (callback) ->
      return unless @file?

      @db.save @model, @toJSON(), @file, callback

    exports.Database = Database
    exports.Model = Model
