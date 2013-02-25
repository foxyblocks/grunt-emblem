Emblem = require 'emblem'

module.exports = (grunt) ->
  description = 'Compile emblem templates into Handlebars.'

  grunt.registerMultiTask 'emblem', description, ->

    options = this.options(
      data: {}
    )

    grunt.verbose.writeflags(options, 'Options')
