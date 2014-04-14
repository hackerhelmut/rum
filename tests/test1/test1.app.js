(function() {
  var application, module;

  application = {
    extend: function(object, properties) {
      var key, name, val;
      name = void 0;
      if (typeof object === 'string') {
        name = object;
        object = application[name] || {};
      }
      for (key in properties) {
        val = properties[key];
        object[key] = val;
      }
      if (name != null) {
        application[name] = object;
      }
      return object;
    }
  };

  application.module.add("mod2.coffee", [], function() {
    return {
      mod2: "Check",
      template: application.template.index["mod2.coffee:4"]
    };
  });
  application.module.add("mod1.coffee", ["mod2"], function(mod2) {
    return {
      mod1: "Check",
      mod2: mod2,
      template: application.template.index["mod1.coffee:5"]
    };
  });
  application.module.add("test1.app.coffee", ["mod1"], function(mod1) {
    var mod2;
    mod2 = application.module.use("mod2");
    return console.log(mod1, mod2);
  });
  module = application.module.use("test1.app.coffee");
  if (module != null) {
    module.exports = module;
  }

}).call(this);
