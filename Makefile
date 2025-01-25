SRC := $(wildcard fnl/*.fnl)
DST_DIR := lua
DST := $(patsubst fnl/%,${DST_DIR}/%,$(patsubst %.fnl,%.lua,$(SRC)))
FNL := ./fennel-1.5.0

.PHONY: build clean

clean:
	rm -rf ./${DST_DIR}

build: $(DST)

# Create the lua output directory if it doesn't exist
${DST_DIR}:
	mkdir ${DST_DIR}

# Compile fnl to lua
${DST_DIR}/%.lua: fnl/%.fnl ${DST_DIR}
	$(FNL) --compile $< > $@

