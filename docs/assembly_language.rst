Assembly language
=================

Programs for the MCI can be written in the built-in assembly language, IAL
(Intermediate Assembly Language). The assembler takes as input a series of
source files and assembles them to a single output file (a module).

The grammar is:

.. productionlist::
    Program : { `TypeDeclaration` | `FunctionDeclaration` | `EntryPointDeclaration` | `ThreadEntryPointDeclaration` | `ThreadExitPointDeclaration` | `ModuleEntryPointDeclaration` | `ModuleExitPointDeclaration` }

Module references have the grammar:

.. productionlist::
    Module : `Identifier`

Some common grammar elements that will be used:

.. productionlist::
    DecimalDigit : "0" .. "9"
    DecimalSequence : `DecimalDigit` { `DecimalDigit` }
    HexadecimalDigit : `DecimalDigit` | "a" .. "f" | "A" .. "F"
    HexadecimalSequence : `HexadecimalDigit` { `HexadecimalDigit` }
    IdentifierCharacter : "." | "_" | 'a' .. 'z' | 'A' .. 'Z'
    Identifier : `IdentifierCharacter` { `IdentifierCharacter` | `DecimalDigit` } | `QuotedIdentifier`
    QuotedIdentifierCharacter : ? any character ? - "'" | "\'"
    QuotedIdentifier : "'" `QuotedIdentifierCharacter` { `QuotedIdentifierCharacter` } "'"
    Literal : [ "+" | "-" ] ( `IntegerLiteral` | `FloatingPointLiteral` | "nan" | "inf" )
    LiteralArray : `Literal` { "," `Literal` }
    IntegerLiteral : `DecimalSequence` | "0x" `HexadecimalSequence`
    FloatingPointLiteral : `DecimalSequence` "." `DecimalSequence` [ "e" [ "+" | "-" ] `DecimalSequence` ]

Line comments are allowed anywhere. They start with ``//`` and go until the
end of the line, e.g.::

    // This is a comment.
    x = ari.add y, z; // Another comment.

Types
+++++

Structure types are aggregates of fields. They can be used to form objects of
strongly typed data, and can be allocated on the stack, the native heap, and
on the GC-managed heap.

Type declarations have the grammar:

.. productionlist::
    TypeDeclaration : [ `MetadataList` ] "type" `Identifier` [ `AlignSpecification` ] "{" { `FieldDeclaration` } "}"
    AlignSpecification : "align" `Literal`

The alignment specification can be used to override the automatic alignment
algorithm that the MCI uses.

Type references have the grammar:

.. productionlist::
    Type : [ `Module` "/" ] `Identifier`

The module reference is optional. If it is not specified, the type is looked
up in the module being assembled.

The grammar for type specifications is:

.. productionlist::
    ReturnType : "void" | `TypeSpecification`
    TypeSpecification : `CoreType` | `Type` | `PointerType` | `ReferenceType` | `ArrayType` | `VectorType` | `StaticArrayType` | `FunctionPointerType`
    PointerType : `TypeSpecification` "*"
    ReferenceType : `TypeSpecification` "&"
    ArrayType : `TypeSpecification` "[" "]"
    VectorType : `TypeSpecification` "[" `Literal` "]"
    StaticArrayType : `TypeSpecification` "{" `Literal` "}"
    FunctionPointerType : `ReturnType` "(" `TypeParameterList` ")" [ `CallingConvention` ]
    TypeParameterList : "(" [ `TypeSpecification` { "," `TypeSpecification` } ] ")"
    CoreType : "int" | "uint" | "int8" | "uint8" | "int16" | "uint16" | "int32 | "uint32" | "int64" | "uint64" | "float32" | "float64"

Fields
------

A field consists of a type, a name, and a storage type. Fields are variables
that represent the physical contents of structure types.

Field declarations have the grammar:

.. productionlist::
    FieldDeclaration : [ `MetadataList` ] "field" `FieldStorage` `TypeSpecification` `Identifier` ";"
    FieldStorage : "instance" | "static" | "thread"

Fields stored as ``instance`` are part of all instances of the type.

Fields stored as ``static`` essentially act as plain old global variables (in
the C sense). They are shared between threads.

Fields marked as ``thread`` go into thread-local storage. They are similar to
``static`` fields in that they are not part of the instance of a type, but
each thread in the program gets a distinct copy of a ``thread`` field.

Field references have the grammar:

.. productionlist::
    Field : `Type` ":" `Identifier`

Functions
+++++++++

Functions are the MCI's answer to the procedure abstraction. A function takes
a number of parameters as input and returns a single output value.

Function declarations have the grammar:

.. productionlist::
    FunctionDeclaration : [ `MetadataList` ] "function" `FunctionAttributes` `ReturnType` `Identifier` `ParameterList` [ `CallingConvention` ] "{" `FunctionBody` "}"
    FunctionAttributes : [ "ssa" ] [ "pure" ] [ "nooptimize" ] [ "noinline" ] [ "noreturn" ] [ "nothrow" ]
    CallingConvention : "cdecl" | "stdcall"
    FunctionBody : { `RegisterDeclaration` | `BasicBlockDeclaration` }

The ``ssa`` attribute specifies that the function is in SSA form. When a
function is in SSA form, registers may only be assigned exactly once (i.e.
using a register without assigning it is illegal), and must have an incoming
definition before being used. The ``copy`` instruction is not allowed in SSA
form. If a function is not in SSA form, the ``phi`` instruction is not
allowed.

The ``pure`` attribute indicates that calls to the function can safely be
reordered as the optimizer and code generator see fit. In other words, the
function is referentially transparent: Calling it with the same arguments at
any point in time will always yield the same result. This attribute should be
used carefully, as incorrect use can result in wrong code generation.

The ``nooptimize`` flag indicates that a function must not be optimized. It
will be ignored entirely by the optimization pipeline.

The ``noinline`` flag prevents a function from being inlined at call sites.

The ``noreturn`` flag indicates that a function does not return normally (e.g.
by using ``return`` or ``leave``). The optimization and code generation
pipeline will assume that any code following a call to a ``noreturn`` function
is effectively dead. Functions marked with ``noreturn`` are still allowed to
throw exceptions, unless also marked ``nothrow``.

The ``nothrow`` flag indicates that a function does not throw any exceptions.
This property is transitive in the sense that all functions called by a
``nothrow`` function are also assumed to be ``nothrow``. If a ``nothrow``
function does throw, behavior is undefined.

Function references have the grammar:

.. productionlist::
    Function : [ `Module` "/" ] `Identifier`

The module reference is optional. If it is not specified, the function is
looked up in the module being assembled.

Parameters
----------

Parameters have the grammar:

.. productionlist::
    Parameter = `ParameterAttributes` `TypeSpecification`
    ParameterAttributes = [ "noescape" ]
    ParameterList : "(" [ [ `MetadataList` ] `Parameter` { "," [ `MetadataList` ] `Parameter` } ] ")"

The ``noescape`` parameter only has significance for pointers, references,
arrays, vectors, and function pointers. It indicates that the function will
not escape an alias (i.e. pointer) to the pointed-to object. This means that
the parameter is guaranteed to only reside in the current stack frame, or
within objects that satisfy this same constraint.

Registers
---------

A register consists of a type and a name. A function can have an arbitrary
amount of registers. If a function is in SSA form, a register can only be
assigned once, and is required to be assigned explicitly before use.

Registers are guaranteed to be completely zeroed out upon function entry.

Register declarations have the grammar:

.. productionlist::
    RegisterDeclaration : [ `MetadataList` ] "register" `TypeSpecification` `Identifier` ";"

The grammar for a register reference is:

.. productionlist::
    Register : `Identifier`

Basic blocks
------------

A basic block is a linear sequence of instructions, containing exactly one
terminator instruction at the end. This terminator instruction can branch to
other basic blocks, return from the function, etc.

Basic block declarations have the grammar:

.. productionlist::
    BasicBlockDeclaration : [ `MetadataList` ] "block" ( "entry" | `Identifier` ) [ `UnwindSpecification` ] "{" `Instruction` { `Instruction` } "}"
    UnwindSpecification : "unwind" `BasicBlock`

The unwind specification is a basic block reference and specifies where to
unwind to if an exception is thrown within the basic block.

The grammar for a basic block reference is:

.. productionlist::
    BasicBlock : "entry" | `Identifier`

Instructions
~~~~~~~~~~~~

Instructions encode the actual logic of a program. They're contained linearly
in basic blocks.

Their grammar is:

.. productionlist::
    Instruction : [ `MetadataList` ] `InstructionAttributes` [ `Register` "=" ] ? any instruction ? [ `Register` [ "," `Register` [ "," `Register` ] ] ] [ `InstructionOperand` ] ";"
    InstructionAttributes : [ "volatile" ]
    InstructionOperand : "(" ( `Literal` | `LiteralArray` | `BasicBlock` | `BranchTarget` | `ForeignFunction` | `TypeSpecification` | `Field` | `Function` ) ")"
    BranchTarget : `BasicBlock` "," `BasicBlock`
    RegisterSelector : `Register` { "," `Register` }
    ForeignFunction : `Identifier` "," `Identifier`

The full list of valid instructions (with register counts, operand types, and
so on) can be found on the instruction set page. Note that the parser is
driven by that information; for example, if an instruction requires a field
reference as operand, the parser will expect to be able to parse one.

The ``volatile`` attribute ensures that an instruction is not reordered (by
the optimization pipeline and code generator) relative to other volatile
instructions. Further, instructions that seem dead (a store followed by a
store to the exact same location, for example) will not be optimized out. This
is useful to model the semantics of the ``volatile`` qualifier in the C family
of languages. Note that it has nothing to do with concurrency.

Some attributes only have meaning for certain instructions. For example, the
``volatile`` attribute has no meaning for instructions that don't involve
memory accesses. Meaningless attributes are allowed on instructions but
optimizers are free to remove them. The linter will also warn about them.

Entry points
++++++++++++

An entry point can be specified for a module. If this is done, the module
effectively becomes executable as a program.

The grammar is:

.. productionlist::
    EntryPointDeclaration : "entry" `Function` ";"

An entry point function must return ``int32``, have no parameters, and have
standard calling convention.

A module entry point can be specified. It will be called before any code
inside the module is executed at all and/or any loads, stores, and address-of
operations on static/TLS fields in the module.

The grammar is:

.. productionlist::
    ModuleEntryPointDeclaration : "module" "entry" `Function` ";"

A module exit point can also be specified. It will be called once a program
has returned from its main entry point.

The grammar is:

.. productionlist::
    ModuleExitPointDeclaration : "module" "exit" `Function` ";"

Module entry and exit points must have no parameters, return ``void``, and
have standard calling convention.

Module entry and exit points will only be called once during a program's
execution time. A module's module exit point is only guaranteed to be called
if that module's module entry point was ever called during execution time.

Module entry points are guaranteed to be called before any thread entry
points. Module exit points are guaranteed to be called after any thread exit
points.

A thread entry point can also be specified. Such an entry point is guaranteed
to run before a properly registered thread gets a chance to execute any other
managed code inside the module. This is useful for initializing TLS data.

The grammar is:

.. productionlist::
    ThreadEntryPointDeclaration : "thread" "entry" `Function` ";"

A thread entry point function must return ``void``, have no parameters, and
have standard calling convention.

Note that thread entry points may be invoked concurrently if multiple threads
enter the virtual machine at the same time. The same holds true for thread
exit points when threads exit.

Thread exit points are also available to help tear down TLS data. They are
guaranteed to be called just before a thread exits, and will only be called
once the thread has stopped executing any other managed code.

The grammar is:

.. productionlist::
    ThreadExitPointDeclaration : "thread" "exit" `Function` ";"

As with thread entry points, these must return ``void``, have no parameters,
and have standard calling convention.

A module's thread exit point is only guaranteed to be called if that module's
thread entry point has been called.

A module can only have one entry point, one thread entry point, one thread
exit point, one module entry point, and one module exit point (all are
optional). They must refer to functions inside the module.

Normally, thread entry and exit points and module entry and exit points will
only be called whenever some thread attempts to access code (or fields) inside
the module they belong to. Some execution engines may, however, choose to load
all of a program's modules eagerly, resulting in these entry and exit points
being executed even if no code inside their module was executed during the
program's execution time.

Code inside thread entry and exit points and module entry and exit points must
not make any assumptions about the order they are called in. The order will
for all practical purposes be deterministic, but this is by no means
guaranteed.

Metadata
++++++++

Metadata can be attached to type declarations, field declarations, function
declarations, register declarations, basic block declarations, and
instructions.

The grammar is:

.. productionlist::
    MetadataList : "[" `MetadataPair` { "," `MetadataPair` } "]"
    MetadataPair : `Identifier` ":" `Identifier`

Metadata is mostly useful to the optimizer and compiler pipeline.
