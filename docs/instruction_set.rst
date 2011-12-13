Instruction set
===============

This page describes the instruction set used in the IAL ISA.

Utility instructions
++++++++++++++++++++

These instructions serve no particular purpose as far as execution goes,
but are useful for annotating the instruction stream.

nop
---

**Has target register**
    No
**Source registers**
    0
**Operand type**
    None

Performs no actual operation. This can be useful to mark regions of code
that will be patched later in the compilation process.

comment
-------

**Has target register**
    No
**Source registers**
    0
**Operand type**
    Byte array

Similar to nop_, but allows attaching arbitrary data to it.

raw
---

**Has target registers**
    No
**Source registers**
    0
**Operand type**
    Byte array

This instruction tells the code generator to insert raw machine code (which
is given as the byte array operand) in the generated machine code stream.

This instruction has a number of consequences:

* The function cannot be pure.
* The function cannot be inlined.
* Calls to other functions cannot be inlined.
* All optimizations that would affect the layout of the stack cannot happen.
* Execution of the function within the interpreter becomes impossible.

Of course, usage of this instruction results in unportable code.

This instruction is primarily intended to allow the implementation of
inline assembly in high-level languages. While it doesn't give a clear way
to access IAL registers, the MCI ABI guarantees a well-defined layout of
locals and arguments on the stack when this instruction is present.

Constant load instructions
++++++++++++++++++++++++++

These instructions load constant values into registers.

load.i8
-------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    8-bit signed integer

Loads a constant 8-bit signed integer into the target register.

The target register must be of type `int8`.

load.ui8
--------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    8-bit unsigned integer

Loads a constant 8-bit unsigned integer into the target register.

The target register must be of type `uint8`.

load.i16
--------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    16-bit signed integer

Loads a constant 16-bit signed integer into the target register.

The target register must be of type `int16`.

load.ui16
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    16-bit unsigned integer

Loads a constant 16-bit unsigned integer into the target register.

The target register must be of type `uint16`.

load.i32
--------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    32-bit signed integer

Loads a constant 32-bit signed integer into the target register.

The target register must be of type `int32`.

load.ui32
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    32-bit unsigned integer

Loads a constant 32-bit unsigned integer into the target register.

The target register must be of type `uint32`.

load.i64
--------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    64-bit signed integer

Loads a constant 64-bit signed integer into the target register.

The target register must be of type `int64`.

load.ui64
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    64-bit unsigned integer

Loads a constant 64-bit unsigned integer into the target register.

The target register must be of type `uint64`.

load.f32
--------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    32-bit floating-point value

Loads a constant 32-bit floating-point value into the target register.

The target register must be of type `float32`.

load.f64
--------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    64-bit floating-point value

Loads a constant 64-bit floating-point value into the target register.

The target register must be of type `float64`.

load.func
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    Function reference

Loads a function pointer to the given function into the target register.

The target register must be of a function pointer type with a signature that
matches the function reference. For example, a function declared as::

    function int32 foo(float32, float64)
    {
        ...
    }

can be assigned to a register declared as::

    register int32(float32, float64) bar;

load.null
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    None

Loads a null value into the target register.

The target register must be a pointer, a function pointer, an array, or a
vector, i.e.::

    register int* a;
    register void(int32) b;
    register float32[] c;
    register int8[3] d;

load.size
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    Type specification

Loads the absolute size of a type specification's layout in memory into the
target register.

The target register must be of type `uint`.

Arithmetic and logic instructions
+++++++++++++++++++++++++++++++++

These instructions provide the basic ALU.

ari.add
-------

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Adds the value in the first source register to the value in the second
source register and stores the result in the target register.

All three registers must be of the exact same type. Allowed types are `int8`,
`uint8`, `int16`, `uint16`, `int32`, `uint32`, `int64`, `uint64`, `int`,
`uint`, `float32`, `float64`, as well as vectors of these. Pointers are
allowed as well.

ari.sub
-------

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Subtracts the value in the first source register from the value in the second
source register and stores the result in the target register.

All three registers must be of the exact same type. Allowed types are `int8`,
`uint8`, `int16`, `uint16`, `int32`, `uint32`, `int64`, `uint64`, `int`,  
`uint`, `float32`, `float64`, as well as vectors of these. Pointers are
allowed as well.

ari.mul
-------

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Multiplies the value in the first source register with the value in the
second source register and stores the result in the target register.

All three registers must be of the exact same type. Allowed types are `int8`,
`uint8`, `int16`, `uint16`, `int32`, `uint32`, `int64`, `uint64`, `int`,  
`uint`, `float32`, `float64`, as well as vectors of these. Pointers are
allowed as well.

ari.div
-------

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Divides the value in the first source register by the value in the second
source register and stores the result in the target register.

All three registers must be of the exact same type. Allowed types are `int8`,
`uint8`, `int16`, `uint16`, `int32`, `uint32`, `int64`, `uint64`, `int`,  
`uint`, `float32`, `float64`, as well as vectors of these. Pointers are
allowed as well.

ari.neg
-------

**Has target register**
    Yes
**Source registers**
    1
**Operand type**
    None

Negates the value in the source register and assigns the result to the target
register.

All three registers must be of the exact same type. Allowed types are `int8`,
`uint8`, `int16`, `uint16`, `int32`, `uint32`, `int64`, `uint64`, `int`,  
`uint`, `float32`, `float64`, as well as vectors of these. Pointers are
allowed as well.

bit.and
-------

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Performs a bit-wise AND operation on the two source registers and assigns
the result to the target register.

Both registers must be of the exact same type. Allowed types are `int8`,
`uint8`, `int16`, `uint16`, `int32`, `uint32`, `int64`, `uint64`, `int`,  
`uint`, `float32`, `float64`, as well as vectors of these. Pointers are
allowed as well.

bit.or
------

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Performs a bit-wise OR operation on the two source registers and assigns
the result to the target register.

All three registers must be of the exact same type. Allowed types are `int8`,
`uint8`, `int16`, `uint16`, `int32`, `uint32`, `int64`, `uint64`, `int`,  
`uint`, `float32`, `float64`, as well as vectors of these. Pointers are
allowed as well.

bit.xor
-------

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Performs a bit-wise XOR operation on the two source registers and assigns
the result to the target register.

All three registers must be of the exact same type. Allowed types are `int8`,
`uint8`, `int16`, `uint16`, `int32`, `uint32`, `int64`, `uint64`, `int`,
`uint`, `float32`, `float64`, as well as vectors of these. Pointers are
allowed as well.

bit.neg
-------

**Has target register**
    Yes
**Source registers**
    1
**Operand type**
    None

Performs a bit-wise, two's complement negation operation on the source
register and assigns the result to the target register.

Both registers must be of the exact same type. Allowed types are `int8`,
`uint8`, `int16`, `uint16`, `int32`, `uint32`, `int64`, `uint64`, `int`,
`uint`, `float32`, `float64`, as well as vectors of these. Pointers are
allowed as well.

not
---

**Has target register**
    Yes
**Source registers**
    1
**Operand type**
    None

Performs a logical negation operation on the source register and assigns the
result to the target register.

If the source equals 0, the result is 1. In all other cases, the result is 0.

Both registers must be of the exact same type. Allowed types are `int8`,
`uint8`, `int16`, `uint16`, `int32`, `uint32`, `int64`, `uint64`, `int`,
`uint`, `float32`, `float64`, as well as vectors of these. Pointers are
allowed as well.

shl
---

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

.. TODO

All three registers must be of the exact same type. Allowed types are `int8`,
`uint8`, `int16`, `uint16`, `int32`, `uint32`, `int64`, `uint64`, `int`,
`uint`, `float32`, `float64`, as well as vectors of these. Pointers are
allowed as well.

shr
---

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

.. TODO

All three registers must be of the exact same type. Allowed types are `int8`,
`uint8`, `int16`, `uint16`, `int32`, `uint32`, `int64`, `uint64`, `int`,
`uint`, `float32`, `float64`, as well as vectors of these. Pointers are
allowed as well.

Memory management instructions
++++++++++++++++++++++++++++++

These instructions are used to allocate and free memory from the system.
There are instructions that operate on the native heap and others that
operate on the GC-managed heap.

mem.alloc
---------

**Has target register**
    Yes
**Source registers**
    1
**Operand type**
    None

Allocates memory from the native heap.

The source register indicates how many elements to allocate memory for.
This means that the total amount of memory allocated is the size of the
target register's element type times the element count. The source
register must be of type `uint`.

If the requested amount of memory could not be allocated, a null pointer
is assigned to the target register; otherwise, the pointer to the allocated
memory is assigned.

The target register must be a pointer, function pointer, or array.

mem.new
-------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    None

Allocates memory from the native heap.

This operation allocates memory for a single fixed-size value. Thus, the
the amount of memory allocated is the size of the element type of the
target register.

If the requested amount of memory could not be allocated, a null pointer
is assigned to the target register; otherwise, the pointer to the allocated
memory is assigned.

The target register must be a pointer, function pointer, or vector.

mem.free
--------

**Has target register**
    No
**Source registers**
    1
**Operand type**
    None

Frees the memory pointed to by a pointer previously allocated with either
mem.alloc_ or mem.new_.

If the pointer passed in is null, no operation is performed. If the pointer
is in some way invalid (e.g. it points to the interior of a block of
allocated memory or has never been allocated in the first place), undefined
behavior occurs.

The source register must be any pointer-like type (that is, a pointer, a
function pointer, an array, or a vector).

mem.gcalloc
-----------

**Has target register**
    Yes
**Source registers**
    1
**Operand type**
    None

Similar to mem.alloc_. This difference is that this instruction allocates
the memory from the GC currently in use.

mem.gcnew
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    None

Similar to mem.new_. The difference is that this instruction allcoates
the memory from the GC currently in use.

mem.gcfree
----------

**Has target register**
    No
**Source registers**
    1
**Operand type**
    None

Similar to mem.free_. The difference is that this instruction frees the
memory from the GC currently in use. Using this instruction  is not usually
necessary, but can be done if desired.

Memory aliasing instructions
++++++++++++++++++++++++++++

mem.get
-------

**Has target register**
    Yes
**Source registers**
    1
**Operand type**
    None

Dereferences the pointer in the source register and assigns the resulting
element value to the target register.

If the deference operation failed in some way (e.g. the source pointer is
null or points to invalid memory), undefined behavior occurs.

The source register must be a pointer, while the target register must be
the element type of the source register's pointer type.

Note in particular that dereferencing function pointers is not allowed.

mem.set
-------

**Has target register**
    No
**Source registers**
    2
**Operand type**
    None

Sets the value of the memory pointed to by the pointer in the first
register to the value of the second register.

If the memory addressing operation failed in some way (e.g. the target
pointer is null or points to invalid memory), undefined behavior occurs.

The first register must be a pointer type, while the second register must
be the element type of the first register's pointer type.

mem.addr
--------

**Has target register**
    Yes
**Source registers**
    1
**Operand type**
    None

Takes the address of the value in the source register and assigns the
address to the target register.

The source register can be of any type, while the target register must be
a pointer to the source register's type.

Array and vector instructions
+++++++++++++++++++++++++++++

array.get
---------

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Fetches at the index given in the second source register from the array
given in the first source register and assigns it to the target register.
The first source register must be an array or vector type, while the
second register must be of type `uint`.

The target vector must be of the first source register's element type.

array.set
---------

**Has target register**
    No
**Source registers**
    3
**Operand type**
    None

Sets the element at the index given in the second source register of the
array given in the first source register to the value in the third source
register. The first source register must be an array or vector type, while
the second register must be of type `uint`. The third register must be of
the element type of the array in the first source register.

array.addr
----------

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Retrieves the address to the element given in the second source register
of the array given in the first source register and assigns it to the
target register. The first source register must be an array or vector
type, while the second source register must be of type `uint`.

The target register must be the first source register's element type.

Structure field instructions
++++++++++++++++++++++++++++

field.get
---------

**Has target register**
    Yes
**Source registers**
    1
**Operand type**
    Field reference

Fetches the value of the field given as the operand on the structure
given in the source register and assigns it to the target register. The
source register must either be a structure or a pointer to a structure
with at most one indirection.

The target register's type must match the field type.

This instruction is only valid on instance fields.

field.set
---------

**Has target register**
    No
**Source registers**
    2
**Operand type**
    Field reference

Sets the value of the field given in the operand on the structure given
in the first source register to the value in the second source register.
The first source register must be a structure or a pointer to a structure
with a most one indirection. The second source register must match the
field's type.

This instruction is only valid on instance fields.

field.addr
----------

**Has target register**
    Yes
**Source registers**
    1
**Operand type**
    Field reference

Gets the address of the field given as the operand on the structure given
in the source register and assigns it to the target register. The source
register must be a structure or pointer to a structure with at most one
indirection.

The target register must be a pointer to the type of the field given in
the operand.

This instruction is only valid on instance fields.

field.gget
----------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    Field reference

Similar to field.get_, but operates on static fields. This means that the
instruction does not need an instance of the structure to fetch the value
of the given field.

This instruction is only valid on static fields.

field.gset
----------

**Has target register**
    No
**Source registers**
    1
**Operand type**
    Field reference

Similar to field.set_, but operates on static fields. This means that the
instruction does not need an instance of the structure to set the value of
the given field.

This instruction is only valid on static fields.

field.gaddr
-----------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    Field reference

Similar to field.addr_, but operates on static fields. This means that the
instruction does not need an instance of the structure to get the address
to the given field.

This instruction is only valid on static fields.

Comparison instructions
+++++++++++++++++++++++

.. TODO

Function invocation instructions
++++++++++++++++++++++++++++++++

.. TODO

Control flow instructions
+++++++++++++++++++++++++

jump
----

**Has target register**
    No
**Source registers**
    0
**Operand type**
    Basic block

Performs an unconditional jump to the specified basic block.

This is a terminator instruction.

jump.true
---------

**Has target register**
    No
**Source registers**
    1
**Operand type**
    Basic block

Performs a jump to the specified basic block if the value in the source
register (which must be of type `uint`) does not equal 0.

This is a terminator instruction.

jump.false
----------

**Has target register**
    No
**Source registers**
    1
**Operand type**
    Basic block

Performs a jump to the specified basic block if the value in the source
register (which must be of type `uint`) equals 0.

This is a terminator instruction.

leave
-----

**Has target register**
    No
**Source registers**
    0
**Operand type**
    None

Leaves (i.e. returns from) the current function. This is only valid if
the function returns void (or, in other words, has no return type).

This is a terminator instruction.

return
------

**Has target register**
    No
**Source registers**
    1
**Operand type**
    None

Returns from the current function with the value in the source register
as the return value. This is only valid in functions that don't return
void (i.e. have a return type).

The source register must be the exact same type as the function's return
type.

This is a terminator instruction.

dead
----

**Has target register**
    No
**Source registers**
    0
**Operand type**
    None

Informs the optimizer of a branch that can safely be assumed unreachable
(and thus optimized out).

This is a terminator instruction.

phi
---

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    Register selector

This instruction is used while the code is in SSA form. Due to the nature
of SSA, it is often necessary to determine which register to use based on
where control flow came from. This instruction picks the register which
was assigned in the basic block control flow entered from and assigns it
to the target register.

This instruction is valid only during analysis and optimization. It must
not appear in code passed to the JIT and AOT engines (but is allowed when
executing under the interpreter).

The target register and selector registers must all be of the same type.

Note that this instruction doesn't count as a control flow instruction.
That is to say, multiple phi instructions are allowed in a basic block
while in SSA form, and they do not act as terminators.

Exception handling instructions
+++++++++++++++++++++++++++++++

.. TODO: Figure out how we want to do EH.

Miscellaneous instructions
++++++++++++++++++++++++++

conv
----

**Has target register**
    Yes
**Source registers**
    1
**Operand type**
    None

Converts the value in the source register from one type to another, and
assigns the resulting value to the target register.

.. TODO: Write semantics.
