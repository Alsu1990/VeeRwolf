VLNV ?= ::veerwolf:0.7.5
TOOL ?= verilator
TARGET ?= sim

vendor = $(shell echo $(VLNV) | cut -d: -f1)
library = $(shell echo $(VLNV) | cut -d: -f2)
name = $(shell echo $(VLNV) | cut -d: -f3)
version = $(shell echo $(VLNV) | cut -d: -f4)

BUILD_DIR = build/${name}_${version}/${TARGET}-${TOOL}

# Debug prints
$(info VLNV: $(VLNV))
$(info TOOL: $(TOOL))
$(info TARGET: $(TARGET))
$(info vendor: $(vendor))
$(info library: $(library))
$(info name: $(name))
$(info version: $(version))
$(info BUILD_DIR: $(BUILD_DIR))

ifeq ($(strip $(name)), veerwolf)
    FLAGS=--flag=cpu_el2
    $(info FLAGS: $(FLAGS))
endif

build:
	@echo "Building ${VLNV} with ${TOOL} for ${TARGET}"
	fusesoc run --target=${TARGET} --tool=${TOOL} --build ${FLAGS} ${VLNV}

${BUILD_DIR}/.build_pass: build
	@echo "Build done"
	touch ${BUILD_DIR}/.build_pass

run: ${BUILD_DIR}/.build_pass
	fusesoc run --target=${TARGET} --tool=${TOOL} --run ${FLAGS} ${VLNV}

all: run

clean:
	rm -rf build/${name}_${version}

.PHONY: build run
