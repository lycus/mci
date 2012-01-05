MODEL ?= 64
BUILD ?= debug
DPLC ?= dmd
PREFIX ?= /usr/local

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

DFLAGS += -w -wi -ignore -property
DFLAGS += -m$(MODEL) -gc
DFLAGS += -Ilibffi-d
DFLAGS += -X -Xf$@.json -deps=$@.deps -of$@

ifeq ($(BUILD), release)
	DFLAGS += -release -O -inline
else
	ifeq ($(BUILD), unittest)
		DFLAGS += unittest
	endif

	DFLAGS += -debug
endif

ifeq ($(BUILD), test)
	MCI_TESTER = bin/mci.tester
endif

.PHONY: all clean docs install uninstall

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
	bin/mci \
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

install: all
	-mkdir -p $(PREFIX);
	cp bin/libmci.core.a $(PREFIX)/lib;
	cp bin/libmci.assembler.a $(PREFIX)/lib;
	cp bin/libmci.linker.a $(PREFIX)/lib;
	cp bin/libmci.verifier.a $(PREFIX)/lib;
	cp bin/libmci.optimizer.a $(PREFIX)/lib;
	cp bin/libmci.vm.a $(PREFIX)/lib;
	cp bin/libmci.compiler.a $(PREFIX)/lib;
	cp bin/libmci.jit.a $(PREFIX)/lib;
	cp bin/libmci.aot.a $(PREFIX)/lib;
	cp bin/libmci.debugger.a $(PREFIX)/lib;
	cp bin/mci $(PREFIX)/bin;
	$(MAKE) -C libffi-d install;

uninstall: all
	if [ -d $(PREFIX) ]; then \
		rm $(PREFIX)/lib/libmci.core.a; \
		rm $(PREFIX)/lib/libmci.assembler.a; \
		rm $(PREFIX)/lib/libmci.linker.a; \
		rm $(PREFIX)/lib/libmci.verifier.a; \
		rm $(PREFIX)/lib/libmci.optimizer.a; \
		rm $(PREFIX)/lib/libmci.vm.a; \
		rm $(PREFIX)/lib/libmci.compiler.a; \
		rm $(PREFIX)/lib/libmci.jit.a; \
		rm $(PREFIX)/lib/libmci.aot.a; \
		rm $(PREFIX)/lib/libmci.debugger.a; \
		rm $(PREFIX)/bin/mci; \
	fi;
	$(MAKE) -C libffi-d uninstall;

libffi-d/bin/libffi-d.a:
	$(MAKE) -C libffi-d;

#################### mci.core ####################

MCI_CORE_SOURCES = \
	src/mci/core/common.d \
	src/mci/core/config.d \
	src/mci/core/container.d \
	src/mci/core/exception.d \
	src/mci/core/io.d \
	src/mci/core/meta.d \
	src/mci/core/nullable.d \
	src/mci/core/tuple.d \
	src/mci/core/visitor.d \
	src/mci/core/analysis/utilities.d \
	src/mci/core/code/emit.d \
	src/mci/core/code/functions.d \
	src/mci/core/code/instructions.d \
	src/mci/core/code/modules.d \
	src/mci/core/code/opcodes.d \
	src/mci/core/diagnostics/debugging.d \
	src/mci/core/tree/base.d \
	src/mci/core/tree/expressions.d \
	src/mci/core/tree/statements.d \
	src/mci/core/typing/cache.d \
	src/mci/core/typing/core.d \
	src/mci/core/typing/members.d \
	src/mci/core/typing/types.d

bin/libmci.core.a: $(MCI_CORE_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_CORE_SOURCES);

#################### mci.assembler ####################

MCI_ASSEMBLER_SOURCES = \
	src/mci/assembler/exception.d \
	src/mci/assembler/disassembly/ast.d \
	src/mci/assembler/disassembly/modules.d \
	src/mci/assembler/generation/driver.d \
	src/mci/assembler/generation/exception.d \
	src/mci/assembler/generation/functions.d \
	src/mci/assembler/generation/modules.d \
	src/mci/assembler/generation/types.d \
	src/mci/assembler/parsing/ast.d \
	src/mci/assembler/parsing/exception.d \
	src/mci/assembler/parsing/lexer.d \
	src/mci/assembler/parsing/parser.d \
	src/mci/assembler/parsing/tokens.d

bin/libmci.assembler.a: $(MCI_ASSEMBLER_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_ASSEMBLER_SOURCES);

#################### mci.linker ####################

MCI_LINKER_SOURCES =

bin/libmci.linker.a: $(MCI_LINKER_SOURCES)
#	-mkdir -p bin;
#	$(DPLC) $(DFLAGS) -lib $(MCI_LINKER_SOURCES);

#################### mci.verifier ####################

MCI_VERIFIER_SOURCES = \
	src/mci/verifier/base.d \
	src/mci/verifier/exception.d \
	src/mci/verifier/manager.d \
	src/mci/verifier/passes/control.d \
	src/mci/verifier/passes/ordering.d \
	src/mci/verifier/passes/typing.d

bin/libmci.verifier.a: $(MCI_VERIFIER_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_VERIFIER_SOURCES);

#################### mci.optimizer ####################

MCI_OPTIMIZER_SOURCES =

bin/libmci.optimizer.a: $(MCI_OPTIMIZER_SOURCES)
#	-mkdir -p bin;
#	$(DPLC) $(DFLAGS) -lib $(MCI_OPTIMIZER_SOURCES);

#################### mci.vm ####################

MCI_VM_SOURCES = \
	src/mci/vm/memory/base.d \
	src/mci/vm/memory/dgc.d \
	src/mci/vm/memory/layout.d \
	src/mci/vm/memory/libc.d \
	src/mci/vm/memory/prettyprint.d \
	src/mci/vm/intrinsics/config.d \
	src/mci/vm/intrinsics/declarations.d \
	src/mci/vm/io/common.d \
	src/mci/vm/io/exception.d \
	src/mci/vm/io/extended.d \
	src/mci/vm/io/reader.d \
	src/mci/vm/io/writer.d \

bin/libmci.vm.a: $(MCI_VM_SOURCES)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) -lib $(MCI_VM_SOURCES);

#################### mci.interpreter ####################

MCI_INTERPRETER_SOURCES =

bin/libmci.interpreter.a: $(MCI_INTERPRETER_SOURCES)
#	-mkdir -p bin;
#	$(DPLC) $(DFLAGS) -lib $(MCI_INTERPRETER_SOURCES);

#################### mci.compiler ####################

MCI_COMPILER_SOURCES =

bin/libmci.compiler.a: $(MCI_COMPILER_SOURCES)
#	-mkdir -p bin;
#	$(DPLC) $(DFLAGS) -lib $(MCI_COMPILER_SOURCES);

#################### mci.jit ####################

MCI_JIT_SOURCES =

bin/libmci.jit.a: $(MCI_JIT_SOURCES)
#	-mkdir -p bin;
#	$(DPLC) $(DFLAGS) -lib $(MCI_JIT_SOURCES);

#################### mci.aot ####################

MCI_AOT_SOURCES =

bin/libmci.aot.a: $(MCI_AOT_SOURCES)
#	-mkdir -p bin;
#	$(DPLC) $(DFLAGS) -lib $(MCI_AOT_SOURCES);

#################### mci.debugger ####################

MCI_DEBUGGER_SOURCES =

bin/libmci.debugger.a: $(MCI_DEBUGGER_SOURCES)
#	-mkdir -p bin;
#	$(DPLC) $(DFLAGS) -lib $(MCI_DEBUGGER_SOURCES);

#################### mci.cli ####################

MCI_CLI_SOURCES = \
	src/mci/cli/main.d \
	src/mci/cli/tool.d \
	src/mci/cli/tools/aot.d \
	src/mci/cli/tools/assembler.d \
	src/mci/cli/tools/debugger.d \
	src/mci/cli/tools/disassembler.d \
	src/mci/cli/tools/interpreter.d \
	src/mci/cli/tools/jit.d \
	src/mci/cli/tools/linker.d \
	src/mci/cli/tools/optimizer.d \
	src/mci/cli/tools/statistics.d \
	src/mci/cli/tools/verifier.d

MCI_CLI_DEPS = \
	bin/libmci.vm.a \
	bin/libmci.verifier.a \
	bin/libmci.assembler.a \
	bin/libmci.core.a \
	libffi-d/bin/libffi-d.a

ifneq ($(shell uname), FreeBSD)
    MCI_CLI_DFLAGS = -L-ldl
endif

bin/mci: $(MCI_CLI_SOURCES) $(MCI_CLI_DEPS)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) $(MCI_CLI_DFLAGS) -L-lffi $(MCI_CLI_SOURCES) $(MCI_CLI_DEPS);

#################### mci.tester ####################

MCI_TESTER_SOURCES = \
	src/mci/tester/common.d \
	src/mci/tester/container.d \
	src/mci/tester/lexer.d \
	src/mci/tester/main.d \
	src/mci/tester/nullable.d \
	src/mci/tester/tokens.d \
	src/mci/tester/types.d

MCI_TESTER_DEPS = \
	bin/libmci.vm.a \
	bin/libmci.verifier.a \
	bin/libmci.assembler.a \
	bin/libmci.core.a \
	libffi-d/bin/libffi-d.a

ifneq ($(shell uname), FreeBSD)
    MCI_TESTER_DFLAGS = -L-ldl
endif

$(MCI_TESTER): $(MCI_TESTER_SOURCES) $(MCI_TESTER_DEPS)
	-mkdir -p bin;
	$(DPLC) $(DFLAGS) $(MCI_TESTER_DFLAGS) -L-lffi $(MCI_TESTER_SOURCES) $(MCI_TESTER_DEPS);
	cd bin; \
	if [ $(BUILD) = "test" ]; then \
		gdb --command=../mci.gdb ../$@; \
	fi;
	cd tests/assembler; \
	rdmd tester.d;
