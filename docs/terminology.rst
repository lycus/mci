Terminology
===========

This document attempts to explain various terms and abbreviations
often used in the MCI source code and documentation.

ALU
+++

Abbreviation for arithmetic logic unit. This refers to the unit in
a processor which performs basic arithmetic and bit-wise operations.

AOT
+++

An abbreviation for ahead of time. It generally refers to either
the technique of compiling code before program execution, or such
a compiler itself.

AST
+++

An abstract tree-based representation of source code. Most parsers
emit an AST from every parsed document, as this is usually the
easiest kind of data structure to work with.

Basic block
+++++++++++

A basic block (or BB, or just block) is a set of instructions which,
in SSA_ form, contains a number of simple instructions terminated by
a single terminator_ instruction. If one were to compare with the C
programming language, a basic block can be considered a label which
a ``goto`` statement can transfer control to.

FFI
+++

Abbreviation for foreign function interface. It can either refer to
the concept of calling a native function dynamically at runtime, or
the actual action of doing so.

GC
++

An abbreviation for garbage collection (or garbage collector), which
refers to the technique of using reachability analysis to determine
whether memory should be freed, instead of placing this burden upon
the programmer.

GC root
+++++++

A GC_ root is a pointer which does not lie within the heap, and is
used by the GC_ to start its reachability analysis from. This usually
includes (but is not necessarily limited to) global fields, local
registers, etc.

Heap
++++

Refers to the data structure the operating system uses to manage its
memory. In general, there are two heaps: The native heap and the
managed heap. The former is what is usually accessed through LibC_'s
``malloc()`` and ``free()`` functions (``mem.alloc`` and ``mem.free`` in
IAL_); the latter is the heap controlled by the GC_ (accessed through
``mem.gcalloc`` and ``mem.gcfree`` in IAL_).

IR
++

Abbreviation for intermediate representation. Computer programs are
usually lowered to IRs to allow easier analysis and optimization for
some specific tasks, but most importantly, in order to make native
code generation easier.

Most IRs are in some kind of linear form, as it is hard to generate
native code directly from a tree-based IR; linear code maps better
to modern processors.

ISA
+++

An abbreviation for instruction set architecture. This generally
refers to the set of machine code instructions available in a
processor architecture (and sometimes other features). It may also
be used to describe the instruction set of IR_\s.

IAL
+++

Abbreviation for Intermediate Assembly Language. This is the IR_
used by in the core of the MCI_ and is a four-address, linear
representation.

It is usually in a static single assignment (SSA_) form while in the
analysis and optimization pipeline, but can also be in non\-SSA_
form (for example, when doing native code generation or when
executing in the interpreter).

JIT
+++

An abbreviation for just in time. It generally refers to either the
technique of compiling code on demand, or such a compiler itself.

LibC
++++

This is the standard library for the C programming language. It is
typically exploited by many other languages, however, as it provides
the easiest access to memory, I/O, and other such facilities which
are very close to the operating system.

MCI
+++

Abbreviation for Managed Compiler Infrastructure.

RTO
+++

An abbreviation for RuntimeObject. Refers to the runtime format and
layout of values in the MCI_, which generally consists of a type pointer,
GC bits, and the user data field.

SSA
+++

Abbreviation for static single assignment. This is a form of IR_
where variables are only assigned once, and so-called phi functions
are used to determine which variable should be used depending on
where control flow came from.

SSA is mostly useful in analysis and optimization.

Target
++++++

Refers to a processor architecture that the MCI_ can compile code for
(therefore, a *target* for code generation).

Terminator
++++++++++

A terminator is an instruction which, while code is in SSA_ form,
indicates the end of a `basic block`_. Only one terminator is allowed
in a `basic block`_, and it must appear as the last instruction. All
basic blocks must end with a terminator.
