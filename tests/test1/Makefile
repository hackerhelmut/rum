BLACKCOFFEE=../../node_modules/.bin/blackcoffee
RUM=../../rum.macro.coffee

all: test1.app.js

%.app.js: %.app.coffee
	$(BLACKCOFFEE) -f template=$(@:.app.js=.template.coffee) -o $@ -m $(@:.js=.map) $(RUM) $<

clean:
	-rm *.app.js *.app.map *.template.coffee1
