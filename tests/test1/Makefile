BLACKCOFFEE=../../node_modules/.bin/blackcoffee
RUM=../../rum.macro.coffee

all: test1.app.js test1.template.js

%.app.js: %.app.coffee
	$(BLACKCOFFEE) -f template=$(@:.app.js=.template.coffee) -o $@ -m $(@:.js=.map) $(RUM) $<

%.template.js: %.template.coffee
	$(BLACKCOFFEE) -o $@ -m $(@:.js=.map) $(RUM) $<

clean:
	-rm *.app.js *.app.map *.template.coffee1
