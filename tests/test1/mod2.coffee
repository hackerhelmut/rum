module ->
  return {
    mod2: "Check"
    template: defineTemplate '''
      h1 Hello World
      p Module 2 sends his regards
        a(href="#") with link
    '''
  }
