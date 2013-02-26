should = require("should")
grunt = require("grunt")
jsdom = require("jsdom")


describe 'with ember', ->
  exampleView = undefined
  renderedView = undefined

  before (done) ->
    templates = grunt.file.read('tmp/emblem-basic.js')


    jsdom.env
      html: "<div id=\"test\"></div>"
      src: [jQueryJs(), handlebarsJs(), emberJs(), templates]
      done: (errors, window) ->
        $ = window.jQuery
        Ember = window.Ember
        Ember.Application.create()
        ExampleView = Ember.View.extend(templateName: "emblem-basic")
        exampleView = ExampleView.create(
          value: "baz"
          context: Ember.Object.create(
            subcontext: Ember.Object.create(value: "foo")
            value: "bar"
          )
        )
        Ember.run ->
          exampleView.appendTo "#test"

        renderedView = $("#test").text()
        done()

  it 'renders view values', ->
    renderedView.should.include exampleView.get("value")

  it "renders context values", ->
    renderedView.should.include exampleView.get("context.value")

  it "renders subcontexts values", ->
    renderedView.should.include exampleView.get("context.subcontext.value")



########################################
# Helpers
#######################################

jQueryJs = -> vendorScript "/jquery-1.9.1.js"
handlebarsJs = -> vendorScript "/handlebars-1.0.0-rc.3.js"
emberJs = -> vendorScript "/ember-1.0.0-rc.1.js"

vendorScript = (path) ->
  vendorDir = __dirname + "/vendor"
  grunt.file.read(vendorDir + path, "utf8")

