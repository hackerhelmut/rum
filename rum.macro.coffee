# Declare rum runtime base instance
application =
  extend: (object, properties) ->
    name = undefined
    if typeof object == 'string'
      name = object
      object = application[name] or {}
    for key, val of properties
      object[key] = val
    if name?
      application[name] = object
    return object

macro ->
# declare rum compiletime base instance
  @application =
    # to extend the base instance with macro modules
    extend: (object, properties) ->
      name = undefined
      if typeof object == 'string'
        name = object
        object = @[name] or {}
      for key, val of properties
        object[key] = val
      if name?
        @[name] = object
      return object

    load: (filename, lang) ->
      fs = macro.require 'fs'
      if not lang?
        lang = 'coffee' if filename.match /\.coffee$/
        lang = 'js' if filename.match /\.js$/
        lang = 'json' if filename.match /\.json$/
        if not lang?
          lang = "coffee"

      if fs.existsSync filename
        filepath = filename
      else if fs.existsSync "#{filename}.#{lang}"
        filepath = "#{filename}.#{lang}"
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

    callbacks: {}

    bind: (event, callback) ->
      @callbacks[event] ?= []
      @callbacks[event].push callback

    unbind: (event, callback) ->
      if @callbacks[event]? and event in @callbacks[event]
        @callbacks[event].splice @callbacks[event].indexOf(callback), 1

    trigger: (event, args) ->
      code = []
      if @callbacks[event]? and @callbacks[event].length > 0
        for callback in @callbacks[event]
          for c in callback args...
            code.push c
      return code

# Load components
macro ->
  @application.load "module.macro"
  @application.load "jade.macro"
  @application.trigger 'load.end', []

# The requirejs like define function
macro module (args...) ->
  block = []
  for code in @application.trigger 'module.begin', args
    block.push code
  for code in @application.trigger 'module.end', args
    block.push code
  return new macro.Block block

macro library (args...) ->
  block = []
  for code in @application.trigger 'library.begin', args
    block.push code
  for code in @application.trigger 'library.end', args
    block.push code
  return new macro.Block block

macro application (args...) ->
  block = []
  for code in @application.trigger 'application.begin', args
    block.push code
  for code in @application.trigger 'application.end', args
    block.push code
  return new macro.Block block

