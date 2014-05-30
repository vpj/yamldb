    yamldb = require './yamldb'

    class Fruit extends yamldb.Model
     @defaults
      handle: ''
      name: ''
      price: 0.00
      description: ''
      images: []

    models =
     Fruit: Fruit

    db = new yamldb.Database 'testdata', models

    db.loadModels 'Fruit', (models) ->
     console.log models

