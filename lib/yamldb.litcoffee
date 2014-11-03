#YAML Database

YAML database is a document database which stores documents as YAML files. The documents in the database can be maintained by simply editing the yaml files.

This database was designed to be used for systems like CMS systems, where an easy way to edit data is necessary and the number of data objects is not very high. It can be also used to store settings and configurations.

Storing the database as separate files lets you use version control systems like git on the database, which is again ideal for storing settings, configurations, blog posts and CMS content.

###Advantages
* Can easily change database entries
* Can use version control on the database
* Ideal for settings and configurations (user configs etc)


###Disadvantages
* No SQL or similar functionality (like searching the database)
* Not suitable for storing transactional data

###Github - [https://github.com/vpj/yamldb](https://github.com/vpj/yamldb)

    fs = require 'fs'
    YAML = require "yamljs"
    findFiles = require '../jshelpers/find_files'

####Load Directory of files
This will load all the files of type `model` recursing over the subdirectories.

    loadDirectory = (options, callback) ->
     path = options.path
     objs = []
     files = []
     err = []
     n = 0

     load = ->
      if n >= files.length
       err = null if err.length is 0
       callback err, objs
       return

      loadFile model: options.model, file: files[n], (e, obj) ->
       if e?
        err.push e
       else
        objs.push obj
       n++
       load()

     findFiles path, (e, f) ->
      err = e
      err ?= []
      files = f
      load()

####Load file
Loads a single file of type model

    loadFile = (options, callback) ->
     fs.readFile options.file, encoding: 'utf8', (e1, data) =>
      if e1?
       callback msg: "Error reading file: #{options.file}", err: e1,
        new options.model {}, file: options.file
       return

      try
       data = YAML.parse data
      catch e2
       callback msg: "Error parsing file: #{options.file}", err: e2,
        new options.model {}, file: options.file
       return
      callback null, (new options.model data, file: options.file)




## Model class
Introduces class level function initialize and include. This class is the base class of all other data models. It has `get` and `set` methods to change values. The structure of the object is defined by `defaults`.

    class Model
     constructor: ->
      @_init.apply @, arguments

     _initialize: []

####Register initialize functions.
All initializer funcitons in subclasses will be called with the constructor arguments.

     @initialize: (func) ->
      @::_initialize = @::_initialize.slice()
      @::_initialize.push func

     _init: ->
      for init in @_initialize
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
      @::_defaults = JSON.parse JSON.stringify @::_defaults
      for k, v of defaults
       @::_defaults[k] = v

Build a model with the structure of defaults. `options.db` is a reference to the `Database` object, which will be used when updating the object. `options.file` is the path of the file, which will be null if this is a new object.

     @initialize (values, options) ->
      @file = options.file
      @isNew = false
      if not @file?
       @isNew = true

      @values = {}
      values ?= {}
      for k, v of @_defaults
       if values[k]?
        @values[k] = values[k]
       else
        @values[k] = v

      for k of values
       if not @_defaults[k]?
        throw new Error "Unknown property #{k}"

####Returns key value set

     toJSON: -> JSON.parse JSON.stringify @values

####Get value of a given key

     get: (key) -> @values[key]

####Set key value combination

     set: (obj) ->
      found = null
      for k, v of obj
       if @_defaults[k]?
        @values[k] = v
       else
        found = k

      if found?
       throw new Error "Unknown property #{found}"


###Save the object

     save: (callback) ->
      return unless @file?
      @isNew = false

      data = YAML.stringify @toJSON(), 1000, 1
      fs.writeFile @file, data, encoding: 'utf8', (err) ->
       callback err

#Exports

    exports.loadFile = loadFile
    exports.loadDirectory = loadDirectory
    exports.Model = Model
