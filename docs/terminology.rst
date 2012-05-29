Terminology
===========

This document attempts to explain various terms and abbreviations often used
in the MCI source code and documentation.

ALU
+++

Abbreviation for arithmetic logic unit. This refers to the unit in a processor
which performs basic arithmetic and bit-wise operations.

AOT
+++

An abbreviation for ahead of time. It generally refers to either the technique
of compiling code before program execution, or such a compiler itself.

AST
+++

An abstract tree-based representation of source code. Most parsers emit an AST
from every parsed document, as this is usually the easiest kind of data
structure to work with.

BB
++

Abbreviation for `basic block`_.

Basic block
+++++++++++

A basic block (or just block) is a set of instructions which, in SSA_ form,
contains a number of simple instructions terminated by a single terminator_
instruction. If one were to compare with the C programming language, a basic
block can be considered a label which a ``goto`` statement can transfer
control to.

CSE
+++

Abbreviation for common sub-expression elimination. This is an optimization
which eliminates duplicate computations in expressions. For instance, in
``x * y + x * y``, the computation of ``x + y`` can be factored out to a
variable ``z`` such that the expression can be rewritten as ``z + z``, thereby
avoiding doing the computation of ``x + y`` twice.

DCE
+++

Abbreviation for dead code elimination. This is an optimization that attempts
to remove code that is definitely unreachable or otherwise considered useless
(i.e. has no impact on the program's semantics). For instance::

    x = 0;
    // ...
    if (x != 0)
    {
        foo();
    }
    else
    {
        bar();
    }

It is trivial to discover that the true branch will never be taken. So, we
optimize to::

    x = 0;
    // ...
    bar();

Further optimization would remove ``x`` entirely.

EP
++

Abbreviation for entry point. An entry point of `main module`_ is called upon
startup and returns the exit code of the program.

FFI
+++

Abbreviation for foreign function interface. It can either refer to the
concept of calling a native function dynamically at runtime, or the actual
action of doing so.

GC
++

An abbreviation for garbage collection (or garbage collector), which refers
to the technique of using reachability analysis to determine whether memory
should be freed, instead of placing this burden upon the programmer.

GC root
+++++++

A GC_ root is a pointer which does not lie within the heap, and is used by the
GC_ to start its reachability analysis from. This usually includes (but is not
necessarily limited to) global fields, local registers, etc.

Heap
++++

Refers to the data structure the operating system uses to manage its memory.
In general, there are two heaps: The native heap and the managed heap. The
former is what is usually accessed through LibC_'s ``malloc()`` and ``free()``
functions; the latter is the heap controlled by the GC_.

IAL
+++

Abbreviation for Intermediate Assembly Language. This is the IR_ used in the
core of the MCI_ and is a four-address, linear representation.

It is usually in a static single assignment (SSA_) form while in the analysis
and optimization pipeline, but can also be in non\-SSA_ form (for example,
when doing native code generation or when executing in the interpreter).

Insn
++++

Abbreviation for instruction.

Instr
+++++

Abbreviation for instruction.

IPA
+++

Inter-procedural analysis. This is the practice of doing things like alias
analysis and function inline cost analysis across function boundaries.

IPO
+++

Inter-procedural optimization. This refers to optimizing across function
boundaries, such as when inlining functions or doing global DCE_.

IR
++

Abbreviation for intermediate representation. Computer programs are usually
lowered to IRs to allow easier analysis and optimization for some specific
tasks, but most importantly, in order to make native code generation easier.

Most IRs are in some kind of linear form, as it is hard to generate native
code directly from a tree-based IR; linear code maps better to modern
processors.

ISA
+++

An abbreviation for instruction set architecture. This generally refers to the
set of machine code instructions available in a processor architecture (and
sometimes other features). It may also be used to describe the instruction set
of IR_\s.

JIT
+++

An abbreviation for just in time. It generally refers to either the technique
of compiling code on demand, or such a compiler itself.

LTO
+++

Link-time optimization. This is the practice of doing IPO_ across modules. As
far as the MCI_ is concerned, this optimization comes for free, as all code
must be available in IR_ form.

LibC
++++

This is the standard library for the C programming language. It is typically
exploited by many other languages, however, as it provides the easiest access
to memory, I/O, and other such facilities which are very close to the
operating system.

MCI
+++

Abbreviation for Managed Compiler Infrastructure.

Main module
+++++++++++

The main module of a program is the module that was passed to the virtual
machine for execution.

PRE
+++

Abbreviation for partial redundancy elimination. This is a form of CSE_ that
tries to eliminate computations that are said to be partially redundant. For
instance, consider this high-level code::

    if (foo)
    {
        x = y - 8;
    }
    else
    {
        // ...
    }
    w = y - 8;

If ``foo`` is true, ``y - 8`` is evaluated twice. This is clearly wasteful, so
this code can be optimized to::

    if (foo)
    {
        x = y - 8;
    }
    else
    {
        // ...
    }
    w = y - 8;

RTO
+++

An abbreviation for RuntimeObject. Refers to the runtime format and layout of
values in the MCI_, which generally consists of a type pointer, GC bits, and
the user data field.

RTV
+++

An abbreviation for RuntimeValue. Refers to a rooted object that holds a
reference to a managed object.

SCCP
++++

Abbreviation for sparse conditional constant propagation. An optimization
performed in SSA_ form. It is strictly more powerful than applying DCE_ and
constant propagation in any order or number of repetitions.

SSA
+++

Abbreviation for static single assignment. This is a form of IR_ where
variables are only assigned once, and so-called phi functions are used to
determine which variable should be used depending on where control flow came
from.

SSA is mostly useful in analysis and optimization.

TEP
+++

Abbreviation for thread entry point. A thread entry point of a `main module`_
is called whenever a properly registered thread enters managed code.

TXP
+++

Abbreviation for thread exit point. A thread exit point of a `main module`_ is
called whenever a properly registered thread exits managed code.

TLS
+++

Abbreviation for thread-local storage. This is a mechanism by which each
thread in a program gets its own isolated version of a variable.

Target
++++++

Refers to a processor architecture that the MCI_ can compile code for
(therefore, a *target* for code generation).

Terminator
++++++++++

A terminator is an instruction which, while code is in SSA_ form, indicates
the end of a `basic block`_. Only one terminator is allowed in a
`basic block`_, and it must appear as the last instruction. All basic blocks
must end with a terminator.
