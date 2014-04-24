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
  path = macro.require 'path'
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

    path: [path.dirname(macro.file), '.']
    load: (filename, lang, searchpath) ->
      fs = macro.require 'fs'
      filepath = undefined
      searchpath ?= @path
      if not lang?
        lang = 'coffee' if filename.match /\.coffee$/
        lang = 'js' if filename.match /\.js$/
        lang = 'json' if filename.match /\.json$/
        if not lang?
          lang = "coffee"

      for dir in searchpath
        if fs.existsSync path.join dir, filename
          filepath = path.join dir, filename
        else if fs.existsSync path.join dir, "#{filename}.#{lang}"
          filepath = path.join dir, "#{filename}.#{lang}"
      if not filepath?
        console.error "File not found: '#{filename}' in serach path:", searchpath
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
  block = []
  block.push @application.load "module.macro"
  #block.push @application.load "jade.macro"
  for code in @application.trigger 'load.end', []
    block.push code
  return new macro.Block block

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
  @application.mainfile = macro.file
  block = []
  for code in @application.trigger 'application.begin', args
    block.push code
  for code in @application.trigger 'application.end', args
    block.push code
  return new macro.Block block

