/++

Welcome to the API documentation for the Managed Compiler Infrastructure! This
is where you'll find generated documentation for the entire API exposed by the
MCI libraries.

Note that it is generally assumed that you have read the full infrastructure
documentation before coming here. A lot of API entry points assume that you are
familiar with how the ISA, type system, virtual machine, garbage collection, and
related parts of the infrastructure work. If you have not read the infrastructure
documentation, please go do so now. You'll save yourself a $(B lot) of time.

$(HR)

A description of the various top-level packages:

$(B $(BIG mci.aot))

Mostly provides utilities to deal with AOT (ahead-of-time) compilation of code,
i.e. reading and writing the special file format used to store machine code and
IAL side-by-side.

$(B $(BIG mci.assembler))

Contains modules for lexing, parsing, and assembling IAL source code. It also
provides modules to disassemble in-memory IAL modules and dump the AST resulting
from a parse operation.

$(B $(BIG mci.compiler))

Holds the core of the machine code compiler. This package contains the abstract
machine code generation and optimization framework, as well as the specific
implementations for the various architectures that we support.

$(B $(BIG mci.core))

This is where most shared utilities are available, such as containers, atomics,
I/O primitives, math helpers, manual memory management utilities, metaprogramming
templates, synchronization primitives, tuples, weak references, etc. In addition
to those, this package also holds the core of the ISA and type system (and the
entire object model backing the MCI). Some analysis infrastructure is also present.

$(B $(BIG mci.debugger))

Contains the base of a cooperative debugger built into the VM (also called a soft
debugger). This package provides only the abstract client/server protocol and
socket-level infrastructure. Individual execution engines are expected to fully
implement the classes in this package.

$(B $(BIG mci.interpreter))

Provides an execution engine built on a software interpreter, also supporting the
debugger protocol. This execution engine is primarily provided as a fully correct
reference implementation of the ISA; it is not meant for production work. It is
mostly architecture-independent and so makes almost no attempts to optimize any
operation.

$(B $(BIG mci.jit))

This package contains the JIT compiler implementation. This package is primarily
concerned with executable code management, architecture-specific trampolines,
low-level stack editing, and so on.

$(B $(BIG mci.linker))

Provides a very simple linker implementation. A set of modules can be passed to
the functions in this module to merge them into a single module. It provides some
simple mechanisms to resolve type and function name conflicts.

$(B $(BIG mci.optimizer))

This is the IR optimization pipeline. It holds all built-in optimization passes,
but allows arbitrary external passes to be incorporated as well. In general, three
kinds of passes exist: A so-called 'code' pass (doesn't care what from the IR is
in), an IR pass (which operates only non-SSA form IR), and an SSA pass (which can
only operate on SSA form IR).

$(B $(BIG mci.verifier))

This is where the verifier lives. It enforces the ISA and type system constraints
in the IR. It is generally useful to ensure that a module can safely be passed to
the MCI pipeline. It also contains some linting tools for finding common low-level
bugs in code.

$(B $(BIG mci.vm))

Provides the virtual machine infrastructure used by all execution engines. This
includes intrinsics, memory management, garbage collectors, threading, I/O utilities
for compiled IAL files, FFI entry point resolution, etc.

$(HR)

If this documentation is not sufficient to help you figure out how an API works,
feel free to send an email to either the Lycus Discuss mailing list (if you're using
the MCI from an external project) or the Lycus Develop mailing list (if you're
working on the MCI itself). Alternatively, drop by the IRC channel!

Macros:
REPOSRCTREE = http://github.com/lycus/mci/tree/master/docs

+/

module index;
