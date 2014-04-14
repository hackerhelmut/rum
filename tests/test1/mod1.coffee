module ['mod2'], (mod2) ->
  return {
    mod1: "Check"
    mod2: mod2
    template: defineTemplate '''
      h1 Hello World
      p This is a test
        a(href="#") with link
    '''
  }
