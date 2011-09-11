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

DFLAGS = -v -w -wi -ignore -X -m$(MODEL) -L-L.

ifeq ($(BUILD), release)
	DFLAGS += -release -O -inline -noboundscheck
else
	ifeq ($(BUILD), test)
		DFLAGS += -unittest
	endif

	DFLAGS += -debug -gc -profile
endif

ifeq ($(BUILD), test)
	MCI_TESTER = mci.tester
else
	MCI_TESTER =
endif

all: \
	libmci.core.a \
	libmci.assembler.a \
	$(MCI_TESTER)

clean:
	-rm -f *.o;
	-rm -f *.a;
	-rm -f *.deps;
	-rm -f *.json;
	-rm -f *.lst;
	-rm -f trace.def;
	-rm -f trace.log;
	-rm -f libmci.core;
	-rm -f libmci.assembler;
	-rm -f mci.tester;

#################### mci.core ####################

MCI_CORE_DFLAGS = $(DFLAGS) -lib -Xf"libmci.core.json" -deps="libmci.core.deps"

libmci.core.a:
	dmd $(MCI_CORE_DFLAGS) -of$@ $(MCI_CORE_SOURCES);

MCI_CORE_SOURCES = \
	mci/core/all.d \
	mci/core/common.d \
	mci/core/config.d \
	mci/core/container.d \
	mci/core/exception.d \
	mci/core/io.d \
	mci/core/meta.d \
	mci/core/nullable.d \
	mci/core/tuple.d \
	mci/core/code/functions.d \
	mci/core/code/instructions.d \
	mci/core/code/opcodes.d \
	mci/core/diagnostics/debugging.d \
	mci/core/tree/base.d \
	mci/core/tree/expressions.d \
	mci/core/tree/statements.d \
	mci/core/typing/core.d \
	mci/core/typing/generics.d \
	mci/core/typing/members.d \
	mci/core/typing/types.d

#################### mci.assembler ####################

MCI_ASSEMBLER_DFLAGS = $(DFLAGS) -lib -Xf"libmci.assembler.json" -deps="libmci.assembler.deps"

libmci.assembler.a: libmci.core.a
	dmd $(MCI_ASSEMBLER_DFLAGS) -of$@ $(MCI_ASSEMBLER_SOURCES) $(MCI_ASSEMBLER_DEPS);

MCI_ASSEMBLER_SOURCES = \
	mci/assembler/all.d \
	mci/assembler/exception.d \
	mci/assembler/parsing/ast.d \
	mci/assembler/parsing/lexer.d \
	mci/assembler/parsing/parser.d \
	mci/assembler/parsing/tokens.d

MCI_ASSEMBLER_DEPS = \
	libmci.core.a

#################### mci.tester #######################

MCI_TESTER_DFLAGS = $(DFLAGS) -Xf"mci.tester.json" -deps="mci.tester.deps"

mci.tester: libmci.core.a libmci.assembler.a
	dmd $(MCI_TESTER_DFLAGS) -of$@ $(MCI_TESTER_SOURCES) $(MCI_TESTER_DEPS);
	if [ ${BUILD} = "test" ]; then \
		gdb --command=mci.gdb mci.tester; \
	fi;

MCI_TESTER_SOURCES = \
	mci/tester/main.d

MCI_TESTER_DEPS = \
	libmci.core.a \
	libmci.assembler.a
