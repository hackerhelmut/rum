###
 RUM Runtime and Module loader and compiletime collector
###
application.extend "module",
  inline: {}
  add: (name, deps, body) ->
    @inline[name] =
      deps: deps
      body: body
      inst: undefined

  use: (name) ->
    if (module = @inline[name])?
      return module.inst ?= module.body (
        for dep in module.deps
          @use dep
      )...
    else if require? and typeof require == 'function'
      return require name
    else
      console.log "Module #{name} " +
        "is not included and no commonjs require is found."

macro ->
  get_name = (name) ->
    return name.replace /(.coffee|.js)$/g, ""

  application = @application
  @application.extend "module",
    inline: {}

    stub: macro.codeToNode ->
      application.module.add name, deps, body

    use: (file) ->
      if not @inline[file]?
        result = application.load file
      return file

    def: (args) ->
      deps = []
      body = macro.valToNode undefined
      name = get_name macro.file
      if args.length == 1
        body = args[0]
      else if args.length == 2
        deps = macro.nodeToVal args[0]
        body = args[1]
      else if args.length == 3
        name = macro.nodeToVal args[0]
        deps = macro.nodeToVal args[1]
        body = args[2]
      else
        console.error "define takes a maximum of 3 arguments"
      
      arg = []
      for dep in deps
        arg.push @use dep
      
      @inline[name] ?= {}
      @inline[name].deps = arg
      @inline[name].body = body

    begin: (app) ->
      code = []
      for name, module of @inline
        code.push @stub.subst
          name: macro.valToNode name
          deps: macro.valToNode (module.deps or [])
          body: module.body
      code.push macro.csToNode "module = application.module.use \"#{app}\""
      code.push macro.csToNode "module?.exports = module"
      return code

  # bind on global events
  @application.bind "application.begin", =>
    @application.module.def arguments
    @application.module.begin get_name macro.file

  @application.bind "library.begin", =>
    @application.module.def arguments
    @application.module.begin get_name macro.file

  @application.bind "module.begin", =>
    @application.module.def arguments

macro use (file) ->
  if typeof file == 'object'
    file = macro.nodeToVal file
  macro.csToNode "application.module.use \"#{@application.module.use file}\""

macro define (args...) ->
  macro.module args...
