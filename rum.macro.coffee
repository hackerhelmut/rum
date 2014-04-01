# Declare rum runtime base instance
application =
  extend: (object, properties) ->
    if typeof object == 'string'
      object = application[object] or {}
    for key, val of properties
      object[key] = val
    return object

macro ->
# declare rum compiletime base instance
  @application =
    # to extend the base instance with macro modules
    extend: (object, properties) ->
      if typeof object == 'string'
        object = application[object] or {}
      for key, val of properties
        object[key] = val
      return object

    load: (filename, lang) ->
      fs = macro.require 'fs'
      if not lang
        lang = 'coffee' if filename.match /\.coffee$/
        lang = 'js' if filename.match /\.js$/
        lang = 'json' if filename.match /\.json$/

      if fs.existsSync(filename)
        filepath = filename
      else if fs.exists("#{filename}.#{lang}")
        filepath = "#{filename}+#{lang}"
      else
        console.error "File not found: '#{filename}'"
        return macro.valToNode '{}'

      code = fs.readFileSync filepath, 'utf8'
      code = code.substr 1 if code.charCodeAt(0)==0xFEFF
      if lang == 'js'
        return macro.jsToNode code
      else if lang == 'json'
        return macro.valToNode code
      else
        # For some reason we need the macro keyword at least
        # once in all files which want to process macros
        code += "\nmacro ->"
        return macro.bcToNode code, filepath

    bind: (event, callback) ->
      @callbacks[event] ?= []
      @callbacks[event].push callback

    unbind: (event, callback) ->
      if @callbacks[event]? and event in @callbacks[event]
        @callbacks[event].splice @callbacks[event].indexOf(callback), 1

    trigger: (event, args) ->
      if @callbacks[event]?
        for callback in @callbacks[event]
          @callbacks[event] args...

# Load components
macro ->
  @application.load "module.macro"
  @application.load "template.macro"
  @application.trigger 'load.end', []

# The requirejs like define function
macro module (args...) ->
  @application.trigger 'module.begin', args
  @application.trigger 'module.end', args

macro library (args...) ->
  @application.trigger 'library.begin', args
  @application.trigger 'library.end', args

macro application (args...) ->
  code = []
  @application.trigger 'application.begin', args
  @application.trigger 'application.end', args

