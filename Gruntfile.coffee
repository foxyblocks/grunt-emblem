require('coffee-script')

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
          'tmp/emblem-basic.js': ['test/fixtures/emblem-basic.emblem']
        options:
          paths:
            jquery: 'test/vendor/jquery-1.9.1.js'
            ember: 'test/vendor/ember-1.0.0-rc.1.js'
            emblem: 'test/vendor/emblem.js'
            handlebars: 'test/vendor/handlebars.runtime.js'

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
