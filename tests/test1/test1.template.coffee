compileTemplate
  'mod2.coffee:4': '''
    h1 Hello World
    p Module 2 sends his regards
      a(href="#") with link
  '''
  'mod1.coffee:5': '''
    h1 Hello World
    p This is a test
      a(href="#") with link
  '''
  # Old templates not found in the current build
  # Have a look at the templates they might just
  # have been moved.
  'mod2.coffee:42': '''
    h1 Hello World
    p Module 2 sends his regards
      a(href="#") with link
  '''
