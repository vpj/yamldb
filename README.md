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

##Installation

    npm install yamldb

##[Documentation](http://vpj.github.io/yamldb/)

##[Example.coffee](http://vpj.github.io/yamldb/example.html)

    yamldb = require 'yamldb'

Define a object model

    class Fruit extends yamldb.Model
     model: 'Fruit'

     @defaults
      handle: ''
      name: ''
      price: 0.00
      description: ''
      images: []

An object of all object models

    models =
     Fruit: Fruit

Initialize database, where `testdata` is the path of the database.

    db = new yamldb.Database 'testdata', models

Load all *Fruit* objects from files within directory `testdata/Fruit`.

    db.loadFiles 'Fruit', (err, objs) ->
     console.log err, objs

