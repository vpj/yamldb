Required repositories

    fs = require 'fs'
    YAML = require "yamljs"
    _ = require 'underscore'

Find files in a directory

    findFiles = (dir, callback) ->
     fileList = []
     err = []

     callbackCount = 0

     done = ->
      callbackCount--
      if callbackCount is 0
       err = null if err.length is 0
       callback err, fileList

     recurse = (path) ->
      callbackCount++
      fs.readdir path, (e1, files) ->
       if e1?
        err.push e1
        done()
        return

       for file in files
        continue if file[0] is '.'
        do (file) ->
         f = "#{path}/#{file}"
         callbackCount++
         fs.stat f, (e2, stats) ->
          if e2?
           err.push e2
           done()
           return

          if stats.isDirectory()
           recurse f
          else if stats.isFile()
           fileList.push f
          done()

       done()

     recurse dir

## Database
Setup the database with a set of models and a directory. The models will reside in subdirectories with the same name.

Each model should be a subclass of `Model` class.

    class Database
     constructor: (path, models) ->
      @models = models
      @path = path

####Save a model

     save: (model, data, file, callback) ->
      data = YAML.stringify data, 1000, 1
      fs.writeFile file, data, encoding: 'utf8', (err) ->
       callback err

####Load files
This will load all the files of type `model` recursing over the subdirectories.

     loadFiles: (model, callback) ->
      path = "#{@path}/#{model}"
      objs = []
      files = []
      err = []
      n = 0

      loadFile = =>
       if n >= files.length
        err = null if err.length is 0
        callback err, objs
        return

       @loadFile model, files[n], (e, obj) ->
        if e?
         err.push e
        else
         objs.push obj
        n++
        loadFile()

      findFiles path, (e, f) ->
       err = e
       err ?= []
       files = f
       loadFile()

####Load file
Loads a single file of type model

     loadFile: (model, file, callback) ->
      fs.readFile file, encoding: 'utf8', (e1, data) =>
       if e1?
        callback "Error reading file: #{file}, #{e1}", null
        return

       try
        data = YAML.parse data
       catch e2
        callback "Error parsing file: #{file}, #{e2}", null
        return
       callback null, new @models[model] data, file: file, db: this




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
      values ?= {}
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


#Exports

    exports.Database = Database
    exports.Model = Model
