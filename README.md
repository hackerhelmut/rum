Rum
===

Rum is a macroset for blackcoffee to make your life easier.
It extends coffeescript through backcoffee macros with the following abilities:

- Sort of require at compile time

  From the starting point of your application we collect all requirements.
  We collect them together in one js file just your declares external resources are seperated.

- TODO: i18n support for applications

  Simply generate i18n json files at compiletime.
  Update them manage them.

- TODO: Inline Template Support without the ability to lose designer maintanace

  Like i18n strings we replace templates and collect them in an single external file so your designer and your programmers have an easier live.
  Here we put tugether what belongs together the View in MVC is the hole view again.


blackcoffee rum applicationsugar => delicious

For example in your main.coffee:

    application
      paths:
        jquery: "bower_components/jquery/lib/jquery.min.js"
      shim:
        jquery:
          exclude: true
      use: ['jquery'], ($) ->
      template = defineTemplate """
        //- Body main template
            By default templates are defined in jade
        h1=title
        p=content
      """
      $ "body"
        .html template
          pretty: true
          locale:
            title: gettext "Hello World"
            content: gettext "Rum is the sugar for your coffee"

This main.coffee can be used:
  
    blackcoffee tools/macros/rum.macro.coffee main.coffee -fcollect-i18n=main.de.json -fcollect-i18n=main.es.json -fcollect-templates=main.jade.coffee

The language json and template files will be updated if they already exist.
The template coffee file needs further compilation it will look like this:

    "main.coffee:8": """
        //- Body main template
            By default templates are defined in jade
        h1=title
        p=content
    """
