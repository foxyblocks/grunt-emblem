jsdom = require 'jsdom'

module.exports = (grunt) ->
  _ = grunt.util._
  description = 'Compile emblem templates into Handlebars.'

  grunt.registerMultiTask 'emblem', description, ->
    window = jsdom.jsdom().createWindow()


    options = @options(
      separator: grunt.util.linefeed + grunt.util.linefeed
    )


    if options.paths.jquery
      window.run grunt.file.read options.paths.jquery, 'utf8'

    window.run grunt.file.read options.paths.handlebars, 'utf8'
    window.run grunt.file.read options.paths.emblem, 'utf8'
    if options.paths.ember
      window.run grunt.file.read options.paths.ember, 'utf8'
      emberEnabled = true
    else
      emberEnabled = false


    grunt.verbose.writeflags(options, 'Options')

    @files.forEach (f) ->
      templates = []

      # iterate files, processing partials and templates separately
      f.src.filter(fileExists).forEach (filepath) ->
        src = grunt.file.read(filepath)
        key = keyForFilePath(filepath, options.root)

        compiler = if emberEnabled then compileEmber else compileVanilla

        try
          compiled = compiler.call(this, src, window, key)
        catch e
          grunt.fail.warn e
          # Warn on and remove invalid source files (if nonull was set).
          grunt.fail.warn "Emblem failed to compile " + filepath + "."

        templates.push(compiled)

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
  # Vanilla Compilation -
  # Compiles the file at provided filepath and returns the output
  ########################################################
  compileVanilla = (src, window, key) ->
    content = window.Emblem.precompile window.Handlebars, src

    """
    var templates = Handlebars.templates = Handlebars.templates || {};
    templates['#{key}'] = Handlebars.template(#{content});
    """

  ########################################################
  # Ember Compilation
  ########################################################
  compileEmber = (src, window, key) ->
    key = JSON.stringify(key)
    compiled = window.Emblem.precompile(window.Ember.Handlebars, src)
    template = "Ember.Handlebars.template(#{compiled})"
    "Ember.TEMPLATES[#{key}] = #{template};"

  ########################################################
  # Key for given filepath
  ########################################################
  keyForFilePath = (filepath, root) ->
    key = filepath
      .replace(new RegExp('\\\\', 'g'), '/') #replace backslashes
      .replace(/\.\w+$/, '') #remove extension
      .replace(root, '')

  ########################################################
  # Filters out missing files
  ########################################################

  fileExists = (filepath) ->
    unless grunt.file.exists(filepath)
      grunt.log.warn "Source file \"" + filepath + "\" not found."
      false
    else
      true

  isPartial = (filepath) ->
    isPartialFilename _.last filepath.split '/'

  isPartialFilename = (filename) ->
    regex = /^_/
    regex.test(filename)
