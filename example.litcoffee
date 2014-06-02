    yamldb = require './index'

A basic database model

    class Fruit extends yamldb.Model
     model: 'Fruit'

     @defaults
      handle: ''
      name: ''
      price: 0.00
      description: ''
      images: []

    models =
     Fruit: Fruit

Initialize database

    db = new yamldb.Database 'testdata', models

Load all objects of model *Fruit*

    db.loadFiles 'Fruit', (err, objs) ->
     console.log err, objs

