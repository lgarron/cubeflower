.PHONY: build
build:
	openscad-auto ./*.scad


.PHONY: publish
publish:
	npm publish
