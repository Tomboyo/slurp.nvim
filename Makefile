root := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
fennel := ./fennel-1.5.1
main_source_dir := src/main/fnl
spec_source_dir := src/spec/fnl
main_source := $(shell find ${main_source_dir}/ -type f -name '*.fnl')
spec_source := $(shell find ${spec_source_dir}/ -type f -name '*.fnl')
main_lua_dir := lua
spec_lua_dir := spec
main_lua := $(patsubst \
  ${main_source_dir}/%, \
	${main_lua_dir}/%, \
	$(patsubst %.fnl,%.lua,$(main_source)))
spec_lua := $(patsubst \
  ${spec_source_dir}/%, \
	${spec_lua_dir}/%, \
	$(patsubst %.fnl,%.lua,$(spec_source)))
nvim_instance_dir := ./.nvim

.PHONY: clean compile test-compile test-setup test info

info:
	$(info $$main_source_dir is [${main_source_dir}])
	$(info $$spec_source_dir is [${spec_source_dir}])
	$(info $$main_source is [${main_source}])
	$(info $$spec_source is [${spec_source}])
	$(info $$main_lua is [${main_lua}])
	$(info $$spec_lua is [${spec_lua}])

clean:
	rm -rf ${main_lua_dir}
	rm -rf ${spec_lua_dir}

clean-nvim-env:
	rm -rf ./.nvim

compile: ${main_lua}

# Note: Though we use busted for testing and busted has a fennel loader, busted
# hasn't released to luarocks since 2023, so we can't use it without running
# busted from source, which would defeat the purpose of using luarocks anyway.
test-compile: compile ${spec_lua}

test-setup:
	./scripts/test-setup

test: compile test-compile test-setup
	./scripts/test "${root}/${spec_lua_dir}/?.lua"

# Compile fnl to lua
# fennel path used so absolute imports resolve correctly (relative to
# src/main/fnl)
lua/%.lua: src/main/fnl/%.fnl
	@mkdir -p $(@D)
	${fennel} --add-fennel-path "${main_source_dir}/?.fnl" \
						--compile $< > $@

spec/%.lua: src/spec/fnl/%.fnl
	@mkdir -p $(@D)
	${fennel} --add-fennel-path "${main_source_dir}/?.fnl" \
		        --add-fennel-path "${spec_source_dir}/?.fnl" \
						--compile $< > $@

