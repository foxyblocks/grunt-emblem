module.exports = (grunt) ->
  # Load this plugin's task(s)
  grunt.loadTasks('tasks')

  # load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    clean:
      test: ['tmp']

    emblem:
      compile:
        files:
          'tmp/emblem-basic.html': ['test/fixtures/emblem-basic.emblem']
        options:
          paths:
            jquery: 'test/vendor/jquery-1.9.0.min.js'
            ember: 'test/vendor/ember.js'
            handlebars: 'test/vendor/handlebars.js'

    simplemocha:
      options:
        globals: ['should']
        timeout: 3000
        ignoreLeaks: false
        ui: 'bdd'
        reporter: 'spec'

      all: { src: 'test/**/*.coffee' }

  # Load the plugin that provides the "uglify" task.
  grunt.registerTask('test', ['clean', 'emblem', 'simplemocha'])

  # Default task(s).
