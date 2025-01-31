SRC := $(wildcard fnl/*.fnl)
DST_DIR := lua
DST := $(patsubst fnl/%,${DST_DIR}/%,$(patsubst %.fnl,%.lua,$(SRC)))
FNL := ./fennel-1.5.0

root := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

.PHONY: build clean test

clean:
	rm -rf ./${DST_DIR}
	rm -rf ./.container-volume/config/nvim
	rm -rf ./.container-volume/data/nvim
	rm -rf ./.container-volume/state/nvim
	rm -rf ./.container-volume/cache/nvim

build: $(DST)

test: build
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

debug: build
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

# Create the lua output directory if it doesn't exist
${DST_DIR}:
	mkdir ${DST_DIR}

# Compile fnl to lua
${DST_DIR}/%.lua: fnl/%.fnl ${DST_DIR}
	$(FNL) --compile $< > $@

