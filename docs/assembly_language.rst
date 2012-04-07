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

Type declarations have the grammar:

.. productionlist::
    TypeDeclaration : "type" `Identifier` [ `AlignSpecification` ] "{" { `FieldDeclaration` } "}"
    AlignSpecification : "align" `Literal`

The alignment specification can be used to override the automatic alignment
algorithm that the MCI uses.

Fields
------

A field consists of a type, a name, and a storage type. Fields are variables
that represent the physical contents of structure types.

Field declarations have the grammar:

.. productionlist::
    FieldDeclaration : "field" `FieldStorage` `Type` `Identifier` ";"
    FieldStorage : "instance" | "static" | "thread"

Instance fields are part of the instance of a type. Static fields are
essentially plain old global variables. Thread-local fields use thread-local
storage (TLS).

Functions
+++++++++

Function declarations have the grammar:

.. productionlist::
    FunctionDeclaration : "function" `FunctionAttributes` `ReturnType` `Identifier` `ParameterList` "{" `FunctionBody` "}"
    FunctionAttributes : [ "ssa" ] [ "pure" ] [ "nooptimize" ] [ "noinline" ]
    ParameterList : "(" [ `Type` { "," `Type` } ] ")"
    FunctionBody : { `RegisterDeclaration` | `BasicBlockDeclaration` }

Registers
---------

A register consists of a type and a name. A function can have an arbitrary
amount of registers. If a function is in SSA form, a register can only be
assigned once.

Register declarations have the grammar:

.. productionlist::
    RegisterDeclaration : "register" `Type` `Identifier` ";"

Basic blocks
------------

A basic block is a linear sequence of instructions, containing exactly one
terminator instruction at the end. This terminator instruction can branch to
other basic blocks, return from the function, etc.

Basic block declarations have the grammar:

.. productionlist::
    BasicBlockDeclaration : "block" `Identifier` [ `UnwindSpecification` ] "{" `Instruction` { `Instruction` } "}"
    UnwindSpecification : "unwind" `Identifier`

The unwind specification is a basic block reference and specifies where to
unwind to if an exception is thrown within the basic block.

Instructions
~~~~~~~~~~~~

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
