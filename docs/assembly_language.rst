Assembly language
=================

Programs for the MCI can be written in the built-in assembly language. The
assembler takes as input a series of source files and assembles them to a
single output file (a module).

The grammar is:

.. productionlist::
    Program : { `TypeDeclaration` | `FunctionDeclaration` }

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

The grammar for type specifications is:

.. productionlist::

Fields
------

A field consists of a type, a name, and a storage type. Fields are variables
that represent the physical contents of structure types.

Field declarations have the grammar:

.. productionlist::
    FieldDeclaration : [ `MetadataList` ] "field" `FieldStorage` `Type` `Identifier` ";"
    FieldStorage : "instance" | "static" | "thread"

Fields stored as ``instance`` are part of all instances of the type.

Fields stored as ``static`` essentially act as plain old global variables (in
the C sense). They are shared between threads.

Fields marked as ``thread`` go into thread-local storage. They are similar to
``static`` fields in that they are not part of the instance of a type, but
each thread in the program gets a distinct copy of a ``thread`` field.

Functions
+++++++++

Functions are the MCI's answer to the procedure abstraction. A function takes
a number of arguments as input and returns a single output value.

Function declarations have the grammar:

.. productionlist::
    FunctionDeclaration : [ `MetadataList` ] "function" `FunctionAttributes` `ReturnType` `Identifier` `ParameterList` "{" `FunctionBody` "}"
    FunctionAttributes : [ "ssa" ] [ "pure" ] [ "nooptimize" ] [ "noinline" ]
    ParameterList : "(" [ `Type` { "," `Type` } ] ")"
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
any point in time will always yield the same results. This attribute should be
used carefully, as incorrect use can result in wrong code generation.

The ``nooptimize`` flag indicates that a function must not be optimized. It
will be ignored entirely by the optimization pipeline.

The ``noinline`` flag prevents a function from being inlined at call sites.

Registers
---------

A register consists of a type and a name. A function can have an arbitrary
amount of registers. If a function is in SSA form, a register can only be
assigned once.

Register declarations have the grammar:

.. productionlist::
    RegisterDeclaration : [ `MetadataList` ] "register" `Type` `Identifier` ";"

Basic blocks
------------

A basic block is a linear sequence of instructions, containing exactly one
terminator instruction at the end. This terminator instruction can branch to
other basic blocks, return from the function, etc.

Basic block declarations have the grammar:

.. productionlist::
    BasicBlockDeclaration : [ `MetadataList` ] "block" `Identifier` [ `UnwindSpecification` ] "{" `Instruction` { `Instruction` } "}"
    UnwindSpecification : "unwind" `Identifier`

The unwind specification is a basic block reference and specifies where to
unwind to if an exception is thrown within the basic block.

Instructions
~~~~~~~~~~~~

Instructions encode the actual logic of a program. They're contained linearly
in basic blocks.

Their grammar is:

.. productionlist::
    Instruction : [ `MetadataList` ] [ `Identifier` "=" ] ? any instruction ? [ `Identifier` [ "," `Identifier` [ "," `Identifier` ] ] ] ";"

The full list of valid instructions can be found on the instruction set page.

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
