jsdom = require 'jsdom'

module.exports = (grunt) ->
  _ = grunt.util._
  description = 'Compile emblem templates into Handlebars.'

  grunt.registerMultiTask 'emblem', description, ->
    window = jsdom.jsdom().createWindow()


    options = @options(
      separator: grunt.util.linefeed + grunt.util.linefeed
    )

    dependencies = options.dependencies

    if dependencies.jquery
      window.run grunt.file.read dependencies.jquery, 'utf8'

    window.run grunt.file.read dependencies.handlebars, 'utf8'
    window.run grunt.file.read dependencies.emblem, 'utf8'
    if dependencies.ember
      window.run grunt.file.read dependencies.ember, 'utf8'
      templateBuilder = new EmberBuilder(window, rootPath: options.root)
    else
      templateBuilder = new VanillaBuilder(window, rootPath: options.root)


    grunt.verbose.writeflags(options, 'Options')

    @files.forEach (f) ->
      templates = []

      # iterate files, processing partials and templates separately
      f.src.filter(fileExists).forEach (filepath) ->
        src = grunt.file.read(filepath)

        try
          templates.push templateBuilder.build(src, filepath)
        catch e
          grunt.fail.warn e
          # Warn on and remove invalid source files (if nonull was set).
          grunt.fail.warn "Emblem failed to compile " + filepath + "."

      if templates.length < 1
        grunt.log.warn "
          Destination not written because compiled
          files were empty."
      else
        writeOutput(templates, f, options.separator)


  ########################################################
  # Writes final output to destination
  ########################################################
  writeOutput = (output, file, separator) ->

    grunt.file.write file.dest, output.join(
      grunt.util.normalizelf(separator)
    )

    grunt.log.writeln "File \"" + file.dest + "\" created."


  ########################################################
  # Filters out missing files
  ########################################################

  fileExists = (filepath) ->
    unless grunt.file.exists(filepath)
      grunt.log.warn "Source file \"" + filepath + "\" not found."
      false
    else
      true


########################################################
# TODO extract these classes
########################################################
class TemplateBuilder
  constructor: (window, options = {}) ->
    @window = window
    @rootPath = options?.rootPath

  keyForFilePath: (filepath) ->
    filepath
      .replace(new RegExp('\\\\', 'g'), '/') #replace backslashes
      .replace(/\.\w+$/, '') #remove extension
      .replace(@rootPath, '')

class EmberBuilder extends TemplateBuilder
  build: (src, filepath) ->
    key = JSON.stringify @keyForFilePath(filepath)
    compiled = @window.Emblem.precompile(@window.Ember.Handlebars, src)
    template = "Ember.Handlebars.template(#{compiled})"
    "Ember.TEMPLATES[#{key}] = #{template};"

class VanillaBuilder extends TemplateBuilder
  build: (src, filepath) ->
    key = @keyForFilePath(filepath)
    content = @window.Emblem.precompile @window.Handlebars, src

    """
    var templates = Handlebars.templates = Handlebars.templates || {};
    templates['#{key}'] = Handlebars.template(#{content});
    """
