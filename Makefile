root := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
fennel := ./fennel-1.5.0
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

.PHONY: clean compile test-compile test info

info:
	$(info $$main_source_dir is [${main_source_dir}])
	$(info $$spec_source_dir is [${spec_source_dir}])
	$(info $$main_lua is [${main_lua}])
	$(info $$spec_lua is [${spec_lua}])
	$(info $$main_source is [${main_source}])
	$(info $$spec_source is [${spec_source}])

clean:
	rm -rf ${main_lua_dir}
	rm -rf ${spec_lua_dir}
	rm -rf ./.container-volume/config/nvim
	rm -rf ./.container-volume/data/nvim
	rm -rf ./.container-volume/state/nvim
	rm -rf ./.container-volume/cache/nvim

compile: ${main_lua_dir} ${main_lua}

test-compile: ${spec_lua_dir} ${spec_lua}

test: compile test-compile
	podman build --tag "nluarocks" -f "${root}/nluarocks/Containerfile" "${root}"
	podman run \
    -v "${root}/.container-volume:/appdata:Z" \
    -e "XDG_CONFIG_HOME=/appdata/config" \
    -e "XDG_CACHE_HOME=/appdata/cache" \
    -e "XDG_DATA_HOME=/appdata/data" \
    -e "XDG_STATE_HOME=/appdata/state" \
    -e "XDG_LOG_FILE=/appdata/log" \
    "nluarocks" \
    sh -c "./nluarocks/init && luarocks test"

debug: compile test-compile
	podman build --tag "nluarocks" -f "${root}/nluarocks/Containerfile" "${root}"
	podman run \
		-it \
    -v "${root}/.container-volume:/appdata:Z" \
    -e "XDG_CONFIG_HOME=/appdata/config" \
    -e "XDG_CACHE_HOME=/appdata/cache" \
    -e "XDG_DATA_HOME=/appdata/data" \
    -e "XDG_STATE_HOME=/appdata/state" \
    -e "XDG_LOG_FILE=/appdata/log" \
    "nluarocks" \
		sh -c "./nluarocks/init && /bin/bash"

${main_lua_dir}:
	mkdir ${main_lua_dir}

${spec_lua_dir}:
	mkdir ${spec_lua_dir}

# Compile fnl to lua
lua/%.lua: src/main/fnl/%.fnl
	${fennel} --compile $< > $@

spec/%.lua: src/spec/fnl/%.fnl
	${fennel} --compile $< > $@

