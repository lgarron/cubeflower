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

.PHONY: bump-dev
bump-dev:
	bun run ./script/bump-dev.ts

.PHONY: reset
reset:
	rm -rf ./node_modules
