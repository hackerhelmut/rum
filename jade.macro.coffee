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
      application.trigger "application.template.define", name, template
      @index[name] = macro.nodeToVal template
      return macro.csToNode "application.template.index[\"#{name}\"]"

    list: (old) ->
      result = ""
      if Object.keys(@index).length != 0
        result = "compileTemplate\n"
        for name, template of @index
          if old[name]?
            template = old[name]
            delete old[name]
          result += "  '#{name}': '''\n#{template.replace /^/gm, "    "}\n  '''\n"
      if Object.keys(old).length != 0
        result += "  # Old templates not found in the current build\n"
        result += "  # Have a look at the templates they might just\n"
        result += "  # have been moved.\n"

        for name, template of old
          result += "  '#{name}': '''\n#{template.replace /^/gm, "    "}\n  '''\n"
      return result

    compile: (templates) ->
      return new macro.Block (for name, template of templates
        macro.jsToNode "application.template.index[#{name}] = #{@engine.compile(template, @options)};"
      )

  @application.bind "application.end", =>
    fs = macro.require 'fs'
    path = macro.require 'path'
    for name, file of flags
      if name == "template"
        if fs.existsSync file
          old = macro.nodeToVal application.load "test1.template.coffee", "coffee", ["."]
        else
          old = {}

        data = @application.template.list old
        fs.writeFileSync(file, data)
    return []

macro defineTemplate (template) ->
  @application.template.define template

macro compileTemplate (template) ->
  if not @application.mainfile?
    @application.template.compile template
  else
    return template

macro executeTemplate (template, options) ->
  @application.template.execute template, options
