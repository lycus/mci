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
endif

all: \
	mci.core/bin/libmci.core.a \
	mci.core/bin/libmci.core \
	mci.assembler/bin/libmci.assembler.a \
	mci.assembler/bin/libmci.assembler

clean:
	-rm -f */bin/*.o
	-rm -f */bin/*.a
	-rm -f */bin/*.deps
	-rm -f */bin/*.json
	-rm -f */bin/*.lst
	-rm -f */bin/trace.def
	-rm -f */bin/trace.log
	-rm -f mci.core/bin/libmci.core
	-rm -f mci.assembler/bin/libmci.assembler

#################### mci.core ####################

MCI_CORE_DFLAGS = $(DFLAGS) -Xf"mci.core/bin/libmci.core.json" -deps="mci.core/bin/libmci.core.deps"

mci.core/bin/libmci.core.a: $(MCI_CORE_SOURCES)
	dmd $(MCI_CORE_DFLAGS) -lib -of$@ $(MCI_CORE_SOURCES);

mci.core/bin/libmci.core: $(MCI_CORE_SOURCES)
	dmd $(MCI_CORE_DFLAGS) -unittest -cov -of$@ $(MCI_CORE_SOURCES);
	if [ ${BUILD} = "test" ]; then \
		cd mci.core/bin; \
		gdb --command=../../mci.gdb libmci.core; \
		cd ../..; \
	fi

MCI_CORE_SOURCES = \
	mci.core/all.d \
	mci.core/common.d \
	mci.core/config.d \
	mci.core/container.d \
	mci.core/exception.d \
	mci.core/io.d \
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

#################### mci.assembler ####################

MCI_ASSEMBLER_DFLAGS = $(DFLAGS) -Xf"mci.assembler/bin/libmci.assembler.json" -deps="mci.assembler/bin/libmci.assembler.deps"
MCI_ASSEMBLER_DFLAGS += -L-lmci.core -L-Lmci.core/bin

mci.assembler/bin/libmci.assembler.a: $(MCI_ASSEMBLER_SOURCES)
	dmd $(MCI_ASSEMBLER_DFLAGS) -lib -of$@ $(MCI_ASSEMBLER_SOURCES);

mci.assembler/bin/libmci.assembler: $(MCI_ASSEMBLER_SOURCES)
	dmd $(MCI_ASSEMBLER_DFLAGS) -unittest -cov -of$@ $(MCI_ASSEMBLER_SOURCES);
	if [ ${BUILD} = "test" ]; then \
		cd mci.assembler/bin; \
		gdb --command=../../mci.gdb libmci.assembler; \
		cd ../..; \
	fi

MCI_ASSEMBLER_SOURCES = \
	mci.assembler/all.d \
	mci.assembler/main.d \
	mci.assembler/parsing/lexer.d \
	mci.assembler/parsing/parser.d \
	mci.assembler/parsing/tokens.d
