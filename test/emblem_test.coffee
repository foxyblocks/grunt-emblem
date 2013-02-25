should = require("should")
grunt = require("grunt")
jsdom = require("jsdom")
# precompiler = require("../tasks/lib/ember-template-compiler")

describe 'basic comparison', ->
  it 'should work', ->
    actual = grunt.file.read('tmp/emblem-basic.html')
    expected = grunt.file.read('test/expected/emblem-basic.html')
    actual.should.eq expected

describe.skip "A compiled template", ->
  before (done) ->
    vendorDir = __dirname + "/vendor"
    jQueryJs = grunt.file.read(vendorDir + "/jquery-1.9.0.js", "utf8")
    handlebarsJs = grunt.file.read(vendorDir + "/handlebars-1.0.rc.3.js", "utf8")
    emberJs = grunt.file.read(vendorDir + "/ember.js", "utf8")
    exampleFile = grunt.file.read("test/example.handlebars")
    compiledSrc = precompiler.precompile(exampleFile)
    templatedSrc = "Ember.TEMPLATES.example = " + "Ember.Handlebars.template(" + compiledSrc + ");"
    jsdom.env
      html: "<div id=\"test\"></div>"
      src: [jQueryJs, handlebarsJs, emberJs, templatedSrc]
      done: (errors, window) ->
        $ = window.jQuery
        Ember = window.Ember

        # Required for templateForName, so Ember can find the template.
        Ember.Application.create()
        ExampleView = Ember.View.extend(templateName: "example")
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


  it "renders view values", ->
    renderedView.should.include exampleView.get("value")

  it "renders context values", ->
    renderedView.should.include exampleView.get("context.value")

  it "renders subcontexts values", ->
    renderedView.should.include exampleView.get("context.subcontext.value")

