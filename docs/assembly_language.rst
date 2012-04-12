Assembly language
=================

Programs for the MCI can be written in the built-in assembly language, IAL
(Intermediate Assembly Language). The assembler takes as input a series of
source files and assembles them to a single output file (a module).

The grammar is:

.. productionlist::
    Program : { `TypeDeclaration` | `FunctionDeclaration` | `EntryPointDeclaration` | `ThreadEntryPointDeclaration` }

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
    TypeSpecification : ( `CoreType` | `Type` ) | `PointerType` | `ReferenceType` | `ArrayType` | `VectorType` | `FunctionPointerType`
    PointerType : `TypeSpecification` "*"
    ReferenceType : `TypeSpecification` "&"
    ArrayType : `TypeSpecification` "[" "]"
    VectorType : `TypeSpecification` "[" `Literal` "]"
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
a number of arguments as input and returns a single output value.

Function declarations have the grammar:

.. productionlist::
    FunctionDeclaration : [ `MetadataList` ] "function" `FunctionAttributes` `ReturnType` `Identifier` `ParameterList` [ `CallingConvention` ] "{" `FunctionBody` "}"
    FunctionAttributes : [ "ssa" ] [ "pure" ] [ "nooptimize" ] [ "noinline" ]
    ParameterList : "(" [ [ `MetadataList` ] `TypeSpecification` { "," [ `MetadataList` ] `TypeSpecification` } ] ")"
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
any point in time will always yield the same results. This attribute should be
used carefully, as incorrect use can result in wrong code generation.

The ``nooptimize`` flag indicates that a function must not be optimized. It
will be ignored entirely by the optimization pipeline.

The ``noinline`` flag prevents a function from being inlined at call sites.

Function references have the grammar:

.. productionlist::
    Function : [ `Module` "/" ] `Identifier`

The module reference is optional. If it is not specified, the function is
looked up in the module being assembled.

Registers
---------

A register consists of a type and a name. A function can have an arbitrary
amount of registers. If a function is in SSA form, a register can only be
assigned once.

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
    BasicBlock : `Identifier`

Instructions
~~~~~~~~~~~~

Instructions encode the actual logic of a program. They're contained linearly
in basic blocks.

Their grammar is:

.. productionlist::
    Instruction : [ `MetadataList` ] [ `Register` "=" ] ? any instruction ? [ `Register` [ "," `Register` [ "," `Register` ] ] ] [ `InstructionOperand` ] ";"
    InstructionOperand : "(" ( `Literal` | `LiteralArray` | `BasicBlock` | `BranchTarget` | `FFISignature` | `TypeSpecification` | `Field` | `Function` ) ")"
    BranchTarget : `BasicBlock` "," `BasicBlock`
    RegisterSelector : `Register` { "," `Register` }
    FFISignature : `Identifier` "," `Identifier`

The full list of valid instructions (with register counts, operand types, and
so on) can be found on the instruction set page.

Entry points
++++++++++++

An entry point can be specified for a module. If this is done, the module
effectively becomes executable as a program.

The grammar is:

.. productionlist::
    EntryPointDeclaration : "entry" `Function` ";"

An entry point function must return ``int32``, have no parameters, and have
standard calling convention.

A thread entry point can also be specified. Such an entry point is guaranteed
to run before a properly registered thread gets a chance to execute any other
managed code. This is useful for initializing TLS data.

The grammar is:

.. productionlist::
    ThreadEntryPointDeclaration : "thread" "entry" `Function` ";"

A thread entry point function must return ``void``, have no parameters, and
have standard calling convention.

A module can only have one entry point and one thread entry point (both are
optional). Both must refer to functions inside the module.

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
