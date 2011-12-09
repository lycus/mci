MODEL ?= 64
BUILD ?= debug
DPLC ?= dmd

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

DFLAGS = -w -wi -ignore -X -m$(MODEL) -profile -Xf$@.json -deps=$@.deps -of$@

ifeq ($(BUILD), release)
	DFLAGS += -release -O -inline
else
	ifeq ($(BUILD), test)
		DFLAGS += -unittest
	endif

	DFLAGS += -debug -gc
endif

ifeq ($(BUILD), test)
	MCI_TESTER = bin/mci.tester
else
	MCI_TESTER =
endif

.PHONY: all clean docs

all: \
	bin/libmci.core.a \
	bin/libmci.assembler.a \
	bin/libmci.vm.a \
	bin/libmci.interpreter.a \
	bin/libmci.jit.a \
	bin/mci.cli \
	$(MCI_TESTER)

clean:
	-rm -rf docs/_build/*
	-rm -f bin/*
	-rm -f tests/*/*/*.ast
	-rm -f tests/*/*/*.mci
	-rm -f tests/*/*/*.def
	-rm -f tests/*/*/*.log

docs:
	cd docs; \
	make html; \
	make dirhtml; \
	make singlehtml; \
	make pickle; \
	make json; \
	make htmlhelp; \
	make qthelp; \
	make devhelp; \
	make epub; \
	make latex; \
	make text; \
	make man; \
	make changes; \
	make linkcheck;

#################### mci.core ####################

bin/libmci.core.a: $(MCI_CORE_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_CORE_SOURCES);

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
	mci/core/visitor.d \
	mci/core/code/emit.d \
	mci/core/code/functions.d \
	mci/core/code/instructions.d \
	mci/core/code/modules.d \
	mci/core/code/opcodes.d \
	mci/core/diagnostics/debugging.d \
	mci/core/tree/base.d \
	mci/core/tree/expressions.d \
	mci/core/tree/statements.d \
	mci/core/typing/cache.d \
	mci/core/typing/core.d \
	mci/core/typing/members.d \
	mci/core/typing/types.d

#################### mci.assembler ####################

bin/libmci.assembler.a: $(MCI_ASSEMBLER_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_ASSEMBLER_SOURCES);

MCI_ASSEMBLER_SOURCES = \
	mci/assembler/all.d \
	mci/assembler/exception.d \
	mci/assembler/disassembly/ast.d \
	mci/assembler/disassembly/modules.d \
	mci/assembler/generation/driver.d \
	mci/assembler/generation/exception.d \
	mci/assembler/generation/functions.d \
	mci/assembler/generation/modules.d \
	mci/assembler/generation/types.d \
	mci/assembler/parsing/ast.d \
	mci/assembler/parsing/exception.d \
	mci/assembler/parsing/lexer.d \
	mci/assembler/parsing/parser.d \
	mci/assembler/parsing/tokens.d

#################### mci.vm ####################

bin/libmci.vm.a: $(MCI_VM_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_VM_SOURCES);

MCI_VM_SOURCES = \
	mci/vm/all.d \
	mci/vm/memory/base.d \
	mci/vm/memory/dgc.d \
	mci/vm/memory/layout.d \
	mci/vm/memory/libc.d \
	mci/vm/memory/prettyprint.d \
	mci/vm/intrinsics/declarations.d \
	mci/vm/intrinsics/io.d \
	mci/vm/intrinsics/memory.d \
	mci/vm/io/common.d \
	mci/vm/io/exception.d \
	mci/vm/io/extended.d \
	mci/vm/io/reader.d \
	mci/vm/io/writer.d \

#################### mci.interpreter ####################

bin/libmci.interpreter.a: $(MCI_INTERPRETER_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_INTERPRETER_SOURCES);

MCI_INTERPRETER_SOURCES = \
	mci/interpreter/all.d

#################### mci.jit ####################

bin/libmci.jit.a: $(MCI_JIT_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_JIT_SOURCES);

MCI_JIT_SOURCES = \
	mci/jit/all.d \

#################### mci.cli ####################

bin/mci.cli: $(MCI_CLI_DEPS) $(MCI_CLI_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) $(MCI_CLI_SOURCES) $(MCI_CLI_DEPS);

MCI_CLI_SOURCES = \
	mci/cli/main.d \
	mci/cli/tool.d \
	mci/cli/tools/assembler.d \
	mci/cli/tools/disassembler.d \
	mci/cli/tools/interpreter.d \
	mci/cli/tools/verifier.d

MCI_CLI_DEPS = \
	bin/libmci.jit.a \
	bin/libmci.interpreter.a \
	bin/libmci.vm.a \
	bin/libmci.assembler.a \
	bin/libmci.core.a

#################### mci.tester ####################

bin/mci.tester: $(MCI_TESTER_DEPS) $(MCI_TESTER_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) $(MCI_TESTER_SOURCES) $(MCI_TESTER_DEPS);
	cd bin; \
	if [ ${BUILD} = "test" ]; then \
		gdb --command=../mci.gdb ../$@; \
	fi;
	cd tests/assembler; \
	rdmd tester.d;

MCI_TESTER_SOURCES = \
	mci/tester/main.d

MCI_TESTER_DEPS = \
	bin/libmci.jit.a \
	bin/libmci.interpreter.a \
	bin/libmci.vm.a \
	bin/libmci.assembler.a \
	bin/libmci.core.a
