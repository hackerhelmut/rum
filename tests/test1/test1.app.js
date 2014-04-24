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

  /*
   RUM Runtime and Module loader and compiletime collector
   */
  application.extend("module", {
    inline: {},
    add: function(name, deps, body) {
      return this.inline[name] = {
        deps: deps,
        body: body,
        inst: void 0
      };
    },
    use: function(name) {
      var dep, module;
      if ((module = this.inline[name]) != null) {
        return module.inst != null ? module.inst : module.inst = module.body.apply(module, (function() {
          var _i, _len, _ref, _results;
          _ref = module.deps;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            dep = _ref[_i];
            _results.push(this.use(dep));
          }
          return _results;
        }).call(this));
      } else if ((typeof require !== "undefined" && require !== null) && typeof require === 'function') {
        return require(name);
      } else {
        return console.log(("Module " + name + " ") + "is not included and no commonjs require is found.");
      }
    }
  });

  /*
   RUM Jade Template engine integration
   */
  application.extend("template", {
    execute: function(template, options) {
      return template(options);
    }
  });

  application.module.add("mod2", [], function() {
    return {
      mod2: "Check",
      template: application.template.index["mod2.coffee:4"]
    };
  });
  application.module.add("mod1", ["mod2"], function(mod2) {
    return {
      mod1: "Check",
      mod2: mod2,
      template: application.template.index["mod1.coffee:5"]
    };
  });
  application.module.add("test1.app", ["mod1"], function(mod1) {
    var mod2;
    mod2 = application.module.use("mod2");
    return console.log(mod1, mod2);
  });
  module = application.module.use("test1.app");
  if (module != null) {
    module.exports = module;
  }

}).call(this);
