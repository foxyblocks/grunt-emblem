should = require("should")
grunt = require("grunt")
jsdom = require("jsdom")


describe 'using compiled templates', ->
  exampleView = undefined
  renderedView = undefined

  before ->
    exampleView = undefined
    renderedView = undefined

  describe 'with ember', ->
    before (done) ->
      templates = grunt.file.read('tmp/emblem-ember.js')

      jsdom.env
        html: "<div id=\"test\"></div>"
        src: [jQueryJs(), handlebarsJs(), emberJs(), templates]
        done: (errors, window) ->
          $ = window.jQuery
          Ember = window.Ember
          Ember.Application.create()
          ExampleView = Ember.View.extend(templateName: "emblem-ember")
          exampleView = ExampleView.create(
            value: "a_value"
            context: Ember.Object.create(
              subcontext: Ember.Object.create(value: "subcontext_value")
              value: "context_value"
            )
          )

          Ember.run ->
            exampleView.appendTo "#test"

          renderedView = $("#test").text()
          done()

    it 'renders view values', ->
      renderedView.should.include "a_value"

    it "renders context values", ->
      renderedView.should.include "context_value"

    it "renders subcontexts values", ->
      renderedView.should.include "subcontext_value"

  describe 'without ember', ->
    before (done) ->
      template = grunt.file.read('tmp/emblem-basic.js')
      jsdom.env
        html: "<div id=\"test\"></div>"
        src: [jQueryJs(), handlebarsJs(), template]
        done: (errors, window) ->
          $ = window.jQuery

          grunt.fail.warn(errors) if errors?

          template = window.Handlebars.templates['emblem-basic']
          data =
            value: 'context_value'
            subcontext:
              value: 'subcontext_value'

          grunt.log.debug template(data)

          $("#test").append template(data)
          renderedView = $("#test").text()
          done()

    it "renders context values", ->
      renderedView.should.include "context_value"

    it "renders subcontexts values", ->
      renderedView.should.include "subcontext_value"

########################################
# Helpers
#######################################

jQueryJs = -> vendorScript "/jquery-1.9.1.js"
handlebarsJs = -> vendorScript "/handlebars-1.0.0-rc.3.js"
emberJs = -> vendorScript "/ember-1.0.0-rc.1.js"

vendorScript = (path) ->
  vendorDir = __dirname + "/vendor"
  grunt.file.read(vendorDir + path, "utf8")


