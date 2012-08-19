Command line tools
==================

The MCI provides a single command line application to access all command line
tools. On most normal installations, this tool is simply called ``mci``.

By running ``mci -h``, you'll get an overview of the tools and parameters that
are supported by the command line interface. This is only a short overview,
though, and doesn't explain exactly how each tool is to be used. This page
will shed some light on that.

General syntax
++++++++++++++

As running just ``mci`` suggests, the command line interface itself has only
two options: ``-h|--help`` and ``-s|--silent``. Generally, the short forms of
the options are preferred, so those will be used in the rest of this document.
The ``-h`` option simply displays the help overview and exits. The ``-s``
option makes the command line interface silent, i.e. it won't output anything
to ``stdout`` and ``stderr``. This is mostly useful if you're running a
program in an execution engine and don't want the 'noise' that the command
line interface normally outputs.

To run a tool, you simply pass its name and arguments to ``mci``. So, for
example, ``mci asm foo.ial -o bar.mci``. This runs the assembler which parses
``foo.ial`` and generates a binary ``bar.mci`` which can be executed. In order
to suppress output, you could also say ``mci -s asm foo.ial -o bar.mci``.

Exit codes
++++++++++

The following primary exit codes can occur:

===== ============================================
Value Description
===== ============================================
0     No errors.
1     A tool-specific error occurred.
2     Some part of command line processing failed.
===== ============================================

Any other exit code is possible too; in particular, the execution engine tools
will return the exit code of the hosted application. The above exit codes are
just the ones that the command line interface is guaranteed to be able to
return.

Tools
+++++

This section details the usage of the specific tools the command line interface
supports. Note that all tool parameters are optional unless stated otherwise.

AOT compiler
------------

**Tool name**
    ``aot``

IAL assembler
-------------

**Tool name**
    ``asm``

This tool assemblies IAL source files into an executable module. Other than the
parameters it takes, all arguments are assumed to be IAL source file names. All
IAL source files must end with the extension ``.ial``.

The ``-o`` parameter specifies which file to write the resulting module to. The
output file name must end in ``.mci``. This defaults to ``out.mci``.

The ``-d`` parameter specifies a dump file for the parsed ASTs. This is mostly
useful for debugging, and not really for general usage.

Soft debugger
-------------

**Tool name**
    ``dbg``

This tool runs an interactive soft debugger client on the command line. It
allows you to connect to an execution engine with a running debugger server
and interact with the program being executed.

IAL disassembler
----------------

**Tool name**
    ``disasm``

Disassembles an assembled module to an IAL source file. It accepts one module
file name only (must end in ``.mci``). In general, this can be used to
round-trip arbitrary IAL code.

The ``-o`` parameter specifies the output file. It must end in ``.ial``. This
defaults to ``out.ial``.

Graph generator
---------------

**Tool name**
    ``graph``

Generates a Graphviz control flow graph for a function. Takes as input exactly
one module file name (must end in ``.mci``) and one function name. This tool
is mostly interesting if you are debugging internals of the MCI.

The ``-o`` parameter specifies the output file name. It must end in ``.dot``.
This defaults to ``out.dot``.

Interpreter
-----------

**Tool name**
    ``interp``

Executes a given module with the IAL interpreter. Accepts exactly one module
file name (must end in ``.mci``). The module must have a valid entry point
function.

The ``-c`` parameter specifies which garbage collector should be used. See
``mci -h`` for possible values.

If the hosted program is started correctly, returns whatever exit code that
program specified.

JIT compiler
------------

**Tool name**
    ``jit``

IAL linker
----------

**Tool name**
    ``link``

Links a set of modules into one module. Accepts a set of module file names as
input (must end in ``.mci``). If there are function or type name clashes, the
selected resolution strategy is used to resolve them.

The ``-r`` parameter specifies which resolution strategy to use. See
``mci -h`` for possible values.

Linter
------

**Tool name**
    ``lint``

Performs various static analyses for correctness on a set of modules. Accepts
as input a set of module file names (must end in ``.mci``).

These analyses are generally not very smart, and can easily give false
positives. They are primarily meant to help spot common errors in emitted IAL
code. Note also that this tool only analyzes SSA functions.

Optimizer
---------

**Tool name**
    ``opt``

Optimizes a set of modules in place. Accepts as input a set of module file
names (must end in ``.mci``).

The ``-p`` option specifies an optimization pass to run. See ``mci -h`` for
possible passes.

The ``-1`` parameter applies all fast optimization passes.

The ``-2`` parameter applies all moderate optimization passes.

The ``-3`` parameter applies all slow optimization passes.

Fast, moderate, and slow refer to the time it takes to run the passes.

Note that none of the parameters above imply any others, so passing e.g.
``-2`` does not imply ``-1``.

The ``-4`` parameter applies all unsafe optimization passes. This allows some
unsafe optimizations to happen which might change the actual semantics of the
program. You should most likely not be using this.

Passes are applied in the exact order they are given on the command line
(duplicate passes are OK and will be run repeatedly in the given order).

IAL verifier
------------

**Tool name**
    ``verify``

Verifies a set of modules for ISA and type system validity. Accepts as input a
set of module file names (must end in ``.mci``).

Note that a module must pass these verification passes in order for it to be
executable in an execution engine.

Statistics
----------

**Tool name**
    ``stats``

Outputs statistics about a set of modules to ``stdout``. Takes as input the
file names of those modules (must end in ``.mci``).

The ``-f`` parameter causes a list of functions to be printed.

The ``-t`` parameter causes a list of types to be printed.
