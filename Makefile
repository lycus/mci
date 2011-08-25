MODEL ?= 64
BUILD ?= debug

ifneq ($(MODEL), 32)
	ifneq ($(MODEL), 64)
		$(error Unsupported architecture: $(MODEL))
	endif
endif

ifneq ($(BUILD), debug)
	ifneq ($(BUILD), release)
		ifneq ($(BUILD), test)
			$(error Unknown build mode: $(BUILD))
		endif
	endif
endif

DFLAGS = -v -w -wi -ignore -X -m$(MODEL)

ifeq ($(BUILD), release)
	DFLAGS += -release -O -inline -noboundscheck
else
	DFLAGS += -debug -gc -profile

	ifeq ($(BUILD), test)
		DFLAGS += -unittest -cov
	endif
endif

all: libmci.core.a

clean:
	-rm -f libmci.*.o
	-rm -f libmci.*.a
	-rm -f libmci.*.deps
	-rm -f libmci.*.json
	-rm -f mci.*.lst

#################### mci.core ####################

MCI_CORE_DFLAGS = $(DFLAGS)
MCI_CORE_DFLAGS += -Xf"libmci.core.json" -deps="libmci.core.deps"

ifneq ($(BUILD), test)
	MCI_CORE_DFLAGS += -lib
endif

libmci.core.a: $(MCI_CORE_SOURCES)
	dmd $(MCI_CORE_DFLAGS) -of$@ $(MCI_CORE_SOURCES);
	if [ ${BUILD} = "test" ]; then \
		gdb --command=mci.gdb libmci.core.a; \
	fi

MCI_CORE_SOURCES = \
	mci.core/all.d \
	mci.core/common.d \
	mci.core/config.d \
	mci.core/container.d \
	mci.core/exception.d \
	mci.core/main.d \
	mci.core/meta.d \
	mci.core/nullable.d \
	mci.core/tuple.d \
	mci.core/code/functions.d \
	mci.core/code/instructions.d \
	mci.core/code/opcodes.d \
	mci.core/diagnostics/debugging.d \
	mci.core/tree/base.d \
	mci.core/tree/expressions.d \
	mci.core/tree/statements.d \
	mci.core/typing/core.d \
	mci.core/typing/generics.d \
	mci.core/typing/members.d \
	mci.core/typing/types.d
