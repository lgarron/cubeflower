.PHONY: build
build:
	openscad-auto ./*.scad

.PHONY: setup
setup: node_modules

node_modules:
	bun install --no-save

.PHONY: publish
publish:
	npm publish
