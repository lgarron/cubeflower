.PHONY: build
build: bun-install
	openscad-auto ./*.scad

.PHONY: setup
setup: node_modules

node_modules:

.PHONY: bun-install
bun-install:
	bun install --no-save

.PHONY: publish
publish:
	npm publish
