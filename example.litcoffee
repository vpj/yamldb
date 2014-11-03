    yamldb = require './lib/yamldb'

A basic database model

    class Fruit extends yamldb.Model
     model: 'Fruit'

     @defaults
      handle: ''
      name: ''
      price: 0.00
      description: ''
      images: []

Load all objects of model *Fruit*

    yamldb.loadDirectory model: Fruit, path: 'testdata', (err, objs) ->
     console.log 'Error: ', err
     console.log 'Data: ', objs

