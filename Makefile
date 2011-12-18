MODEL ?= 64
BUILD ?= debug
DPLC ?= dmd

ifneq ($(MODEL), 32)
	ifneq ($(MODEL), 64)
		$(error Unsupported pointer length: $(MODEL))
	endif
endif

ifneq ($(BUILD), debug)
	ifneq ($(BUILD), release)
		ifneq ($(BUILD), test)
			$(error Unknown build mode: $(BUILD))
		endif
	endif
endif

DFLAGS = -w -wi -ignore -profile -m$(MODEL) -X -Xf$@.json -deps=$@.deps -of$@ -Ilibffi-d

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
endif

.PHONY: all clean docs

all: \
	bin/libmci.core.a \
	bin/libmci.assembler.a \
	bin/libmci.linker.a \
	bin/libmci.verifier.a \
	bin/libmci.optimizer.a \
	bin/libmci.vm.a \
	bin/libmci.interpreter.a \
	bin/libmci.compiler.a \
	bin/libmci.jit.a \
	bin/libmci.aot.a \
	bin/libmci.debugger.a \
	bin/mci.cli \
	$(MCI_TESTER)

clean:
	-rm -rf docs/_build/*;
	-rm -f bin/*;
	-rm -f tests/*/*/*.ast;
	-rm -f tests/*/*/*.mci;
	-rm -f tests/*/*/*.def;
	-rm -f tests/*/*/*.log;
	$(MAKE) -C libffi-d clean;

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

libffi-d/bin/libffi-d.a:
	$(MAKE) -C libffi-d;

#################### mci.core ####################

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

bin/libmci.core.a: $(MCI_CORE_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_CORE_SOURCES);

#################### mci.assembler ####################

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

bin/libmci.assembler.a: $(MCI_ASSEMBLER_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_ASSEMBLER_SOURCES);

#################### mci.linker ####################

MCI_LINKER_SOURCES = \
	mci/linker/all.d

bin/libmci.linker.a: $(MCI_LINKER_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_LINKER_SOURCES);

#################### mci.verifier ####################

MCI_VERIFIER_SOURCES = \
	mci/verifier/all.d \

bin/libmci.verifier.a: $(MCI_VERIFIER_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_VERIFIER_SOURCES);

#################### mci.optimizer ####################

MCI_OPTIMIZER_SOURCES = \
	mci/optimizer/all.d \

bin/libmci.optimizer.a: $(MCI_OPTIMIZER_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_OPTIMIZER_SOURCES);

#################### mci.vm ####################

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

bin/libmci.vm.a: $(MCI_VM_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_VM_SOURCES);

#################### mci.interpreter ####################

MCI_INTERPRETER_SOURCES = \
	mci/interpreter/all.d

bin/libmci.interpreter.a: $(MCI_INTERPRETER_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_INTERPRETER_SOURCES);

#################### mci.compiler ####################

MCI_COMPILER_SOURCES = \
	mci/compiler/all.d \

bin/libmci.compiler.a: $(MCI_COMPILER_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_COMPILER_SOURCES);

#################### mci.jit ####################

MCI_JIT_SOURCES = \
	mci/jit/all.d \

bin/libmci.jit.a: $(MCI_JIT_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_JIT_SOURCES);

#################### mci.aot ####################

MCI_AOT_SOURCES = \
	mci/aot/all.d \

bin/libmci.aot.a: $(MCI_AOT_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_AOT_SOURCES);

#################### mci.debugger ####################

MCI_DEBUGGER_SOURCES = \
	mci/debugger/all.d \

bin/libmci.debugger.a: $(MCI_DEBUGGER_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_DEBUGGER_SOURCES);

#################### mci.cli ####################

MCI_CLI_SOURCES = \
	mci/cli/main.d \
	mci/cli/tool.d \
	mci/cli/tools/assembler.d \
	mci/cli/tools/disassembler.d \
	mci/cli/tools/interpreter.d \
	mci/cli/tools/verifier.d

MCI_CLI_DEPS = \
	bin/libmci.debugger.a \
	bin/libmci.aot.a \
	bin/libmci.jit.a \
	bin/libmci.compiler.a \
	bin/libmci.interpreter.a \
	bin/libmci.vm.a \
	bin/libmci.optimizer.a \
	bin/libmci.verifier.a \
	bin/libmci.linker.a \
	bin/libmci.assembler.a \
	bin/libmci.core.a \
	libffi-d/bin/libffi-d.a

bin/mci.cli: $(MCI_CLI_SOURCES) $(MCI_CLI_DEPS)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -L-lffi -L-ldl $(MCI_CLI_SOURCES) $(MCI_CLI_DEPS);

#################### mci.tester ####################

MCI_TESTER_SOURCES = \
	mci/tester/main.d

MCI_TESTER_DEPS = \
	bin/libmci.debugger.a \
	bin/libmci.aot.a \
	bin/libmci.jit.a \
	bin/libmci.compiler.a \
	bin/libmci.interpreter.a \
	bin/libmci.vm.a \
	bin/libmci.optimizer.a \
	bin/libmci.verifier.a \
	bin/libmci.linker.a \
	bin/libmci.assembler.a \
	bin/libmci.core.a \
	libffi-d/bin/libffi-d.a

$(MCI_TESTER): $(MCI_TESTER_SOURCES) $(MCI_TESTER_DEPS)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -L-lffi -L-ldl $(MCI_TESTER_SOURCES) $(MCI_TESTER_DEPS);
	cd bin; \
	if [ $(BUILD) = "test" ]; then \
		gdb --command=../mci.gdb ../$@; \
	fi;
	cd tests/assembler; \
	rdmd tester.d;
