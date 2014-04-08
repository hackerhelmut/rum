###
 RUM Jade Template engine integration
###
#
application.extend "template",
  execute: (template, options) ->
    return template(options)

macro ->
  application = @application
  @application.extend "template",
    engine: macro.require 'jade'
    options:
      pretty: true
    index: {}
    define: (template, options) ->
      name = "#{macro.file}:#{macro.line}"
      @index[name] = macro.nodeToVal template
      return macro.csToNode "application.template.index[\"#{name}\"]"

    list: ->
      result = ""
      if @index.length != 0
        result = "compileTemplate\n"
        for name, template of @index
          result+= "  \"#{name}\": '''\n#{template}\n'''\n"
      return result

    compile: (templates) ->
      return new macro.Block (for name, template of templates
        macro.jsToNode "application.template.index[#{name}] = #{@engine.compile(template, @options)};"
      )

  @application.bind "application.end", =>
    fs = macro.require 'fs'
    data = @application.template.list()
    for name, file of flags
      if name == "template"
        fs.writeFileSync(file, data)
    return []

macro defineTemplate (template) ->
  @application.template.define template

macro compileTemplate (template) ->
  @application.template.compile template

macro executeTemplate (template, options) ->
  @application.template.execute template, options
