jsdom = require 'jsdom'

module.exports = (grunt) ->
  description = 'Compile emblem templates into Handlebars.'

  grunt.registerMultiTask 'emblem', description, ->
    window = jsdom.jsdom().createWindow()


    options = @options()

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

    grunt.log.debug('Ember Enabled: ' + emberEnabled)

    @files.forEach (f) ->
      partials = []
      templates = []

      # iterate files, processing partials and templates separately
      f.src.filter(fileExists).forEach (filepath) ->
        try
          templates.push(
            if emberEnabled
              compileEmberFilepath(filepath, window, options.root)
            else
              compileFilepath(filepath, window, options.root)
          )
        catch e
          grunt.fail.warn e
          # Warn on and remove invalid source files (if nonull was set).
          grunt.fail.warn "Emblem failed to compile " + filepath + "."


      output = partials.concat(templates)

      if output.length < 1
        grunt.log.warn "Destination not written because compiled files were empty."
      else
        writeOutput(output, f, options.separator)


  ########################################################
  ## Writes final output to destination
  ########################################################
  writeOutput = (output, file, separator) ->

    grunt.file.write file.dest, output.join(
      # grunt.util.normalizelf(separator)
    )

    grunt.log.writeln "File \"" + file.dest + "\" created."


  ########################################################
  # Vanilla Compilation -
  # Compiles the file at provided filepath and returns the output
  ########################################################
  compileFilepath = (filepath, window, root) ->
    key = filepath
      .replace(new RegExp('\\\\', 'g'), '/') #replace backslashes
      .replace(/\.\w+$/, '')
      .replace(root, '')
    src = grunt.file.read(filepath)
    content = window.Emblem.precompile window.Handlebars, src

    result = "var templates = Handlebars.templates = Handlebars.templates || {}; templates['#{key}'] = Handlebars.template(#{content})"


  ########################################################
  # Ember Compilation
  ########################################################
  compileEmberFilepath = (filepath, window, root) ->
    src = grunt.file.read(filepath)
    key = filepath
      .replace(new RegExp('\\\\', 'g'), '/') #replace backslashes
      .replace(/\.\w+$/, '')
      .replace(root, '')

    content = window.Emblem.precompile window.Ember.Handlebars, src
    result = "Ember.TEMPLATES[#{JSON.stringify(key)}] =" +
             "Ember.Handlebars.template(#{content});" +
             "module.exports = module.id;"


  ########################################################
  # Filters out missing files
  ########################################################
  fileExists = (filepath) ->
    unless grunt.file.exists(filepath)
      grunt.log.warn "Source file \"" + filepath + "\" not found."
      false
    else
      true

