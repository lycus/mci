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

The target register must be of type ``int8``.

load.ui8
--------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    8-bit unsigned integer

Loads a constant 8-bit unsigned integer into the target register.

The target register must be of type ``uint8``.

load.i16
--------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    16-bit signed integer

Loads a constant 16-bit signed integer into the target register.

The target register must be of type ``int16``.

load.ui16
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    16-bit unsigned integer

Loads a constant 16-bit unsigned integer into the target register.

The target register must be of type ``uint16``.

load.i32
--------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    32-bit signed integer

Loads a constant 32-bit signed integer into the target register.

The target register must be of type ``int32``.

load.ui32
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    32-bit unsigned integer

Loads a constant 32-bit unsigned integer into the target register.

The target register must be of type ``uint32``.

load.i64
--------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    64-bit signed integer

Loads a constant 64-bit signed integer into the target register.

The target register must be of type ``int64``.

load.ui64
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    64-bit unsigned integer

Loads a constant 64-bit unsigned integer into the target register.

The target register must be of type ``uint64``.

load.f32
--------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    32-bit floating-point value

Loads a constant 32-bit floating-point value into the target register.

The target register must be of type ``float32``.

load.f64
--------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    64-bit floating-point value

Loads a constant 64-bit floating-point value into the target register.

The target register must be of type ``float64``.

load.i8a
--------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    8-bit signed integer array

Loads a constant array of 8-bit signed integers into the target register.

The target register must be of type ``int8[]`` or a vector of ``int8`` with
an element count matching that of the array operand.

load.ui8a
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    8-bit unsigned integer array

Loads a constant array of 8-bit unsigned integers into the target register.

The target register must be of type ``uint8[]`` or a vector of ``uint8``
with an element count matching that of the array operand.

load.i16a
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    16-bit signed integer array

Loads a constant array of 16-bit signed integers into the target register.

The target register must be of type ``int16[]`` or a vector of ``int16``
with an element count matching that of the array operand.

load.ui16a
----------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    16-bit unsigned integer array

Loads a constant array of 16-bit unsigned integers into the target register.

The target register must be of type ``uint16[]`` or a vector of ``uint16``
with an element count matching that of the array operand.

load.i32a
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    32-bit signed integer array

Loads a constant array of 32-bit signed integers into the target register.

The target register must be of type ``int32[]`` or a vector of ``int32``
with an element count matching that of the array operand.

load.ui32a
----------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    32-bit unsigned integer array

Loads a constant array of 32-bit unsigned integers into the target register.

The target register must be of type ``uint32[]`` or a vector of ``uint32``
with an element count matching that of the array operand.

load.i64a
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    64-bit signed integer array

Loads a constant array of 64-bit signed integers into the target register.

The target register must be of type ``int64[]`` or a vector of ``int64``
with an element count matching that of the array operand.

load.ui64a
----------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    64-bit unsigned integer array

Loads a constant array of 64-bit unsigned integers into the target register.

The target register must be of type ``uint64[]`` or a vector of ``uint64``
with an element count matching that of the array operand.

load.f32a
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    32-bit floating-point value array

Loads a constant array of 32-bit floating-point values into the target
register.

The target register must be of type ``float32[]`` or a vector of ``float32``
with an element count matching that of the array operand.

load.f64a
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    64-bit floating-point value array

Loads a constant array of 64-bit floating-point values into the target
register.

The target register must be of type ``float64[]`` or a vector of ``float64``
with an element count matching that of the array operand.

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

The target may also have a specified calling convention (``cdecl`` or
``stdcall``), in which case the given function must be an FFI function with
a matching calling convention.

load.null
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    None

Loads a null value into the target register.

The target register must be a pointer, a function pointer, an array, a
vector, or a reference.

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

Note that for vectors, this is not the full size of the vector, but rather
the size of the reference to the vector (as with arrays and pointers).

The target register must be of type ``uint``.

load.align
----------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    Type specification

Loads the alignment of a type specification into the target register.

The target register must be of type ``uint``.

load.offset
-----------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    Field reference

Loads the offset of a field in its containing structure type into the
target register.

The target register must be of type ``uint``.

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

All three registers must be of the exact same type. Allowed types are
``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``,
``int64``, ``uint64``, ``int``, ``uint``, ``float32``, ``float64``, as
well as any pointer type. Vectors of all of these are also allowed.

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

All three registers must be of the exact same type. Allowed types are
``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``,
``int64``, ``uint64``, ``int``, ``uint``, ``float32``, ``float64``, as
well as any pointer type. Vectors of all of these are also allowed.

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

All three registers must be of the exact same type. Allowed types are
``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``,
``int64``, ``uint64``, ``int``, ``uint``, ``float32``, ``float64``, as
well as any pointer type. Vectors of all of these are also allowed.

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

All three registers must be of the exact same type. Allowed types are
``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``,
``int64``, ``uint64``, ``int``, ``uint``, ``float32``, ``float64``, as
well as any pointer type. Vectors of all of these are also allowed.

ari.rem
-------

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Computes the remainder resulting from dividing the first source register
with the second source register and stores the result in the target
register.

All three registers must be of the exact same type. Allowed types are
``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``,
``int64``, ``uint64``, ``int``, ``uint``, ``float32``, ``float64``, as
well as any pointer type. Vectors of all of these are also allowed.

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

Both registers must be of the exact same type. Allowed types are
``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``,
``int64``, ``uint64``, ``int``, ``uint``, ``float32``, ``float64``, as
well as any pointer type. Vectors of all of these are also allowed.

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

All three registers must be of the exact same type. Allowed types are
``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``,
``int64``, ``uint64``, ``int``, ``uint``, as well as any pointer type.
Vectors of all of these are also allowed.

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

All three registers must be of the exact same type. Allowed types are
``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``,
``int64``, ``uint64``, ``int``, ``uint``, as well as any pointer type.
Vectors of all of these are also allowed.

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

All three registers must be of the exact same type. Allowed types are
``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``,
``int64``, ``uint64``, ``int``, ``uint``, as well as any pointer type.
Vectors of all of these are also allowed.

bit.neg
-------

**Has target register**
    Yes
**Source registers**
    1
**Operand type**
    None

Performs a bit-wise complement negation operation on the source register
and assigns the result to the target register.

Both registers must be of the exact same type. Allowed types are
``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``,
``int64``, ``uint64``, ``int``, ``uint``, as well as any pointer type.
Vectors of all of these are also allowed.

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

Both registers must be of the exact same type. Allowed types are
``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``,
``int64``, ``uint64``, ``int``, ``uint``, ``float32``, ``float64``, as
well as any pointer type. Vectors of all of these are also allowed.

shl
---

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Shifts the bits of the first source register to the left by the amount given
in the second source register and assigns the result to the target register.

If the second source register is larger than the amount of bits of the first
source register's type, that amount will be used instead.

The first register and the target register must be of the exact same type.
Allowed types are ``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``,
``uint32``, ``int64``, ``uint64``, ``int``, ``uint``, as well as any pointer
type. Vectors of all of these are also allowed.

The second register must be of type ``uint`` or a vector of these.

shr
---

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Shifts the bits of the first source register to the right by the amount given
in the second source register and assigns the result to the target register.

If the type of the values being shifted is signed, the shift is an arithmetic
shift (i.e. it is done with sign extension); otherwise, a logical shift is done
(i.e. zero extension is used).

If the second source register is larger than the amount of bits of the first
source register's type, that amount will be used instead.

The first register and the target register must be of the exact same type.
Allowed types are ``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``,
``uint32``, ``int64``, ``uint64``, ``int``, ``uint``, as well as any pointer
type. Vectors of all of these are also allowed.

The second register must be of type ``uint`` or a vector of these.

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

Allocates memory from either the native heap (if the target register is a
pointer) or from the GC currently in use (if the target register is an
array).

The source register indicates how many elements to allocate memory for.
This means that if the target register is a pointer, the total amount of
memory allocated is the size of the target register's element type times
the element count. Otherwise, it represents the amount of array elements
to be allocated. The source register must be of type ``uint``.

If the requested amount of memory could not be allocated, a null pointer
is assigned to the target register; otherwise, the pointer to the allocated
memory is assigned.

If the allocation was successful, all allocated memory is guaranteed to be
completely zeroed out.

The target register must be a pointer or an array.

mem.new
-------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    None

Allocates memory from the native heap (if the target register is a pointer)
or from the GC currently in use (if the target register is a reference or a
vector).

This operation allocates memory for a single fixed-size value. Thus, the
the amount of memory allocated is the size of the element type of the
target register (for vectors, this includes all elements).

If the requested amount of memory could not be allocated, a null pointer
is assigned to the target register; otherwise, the pointer to the allocated
memory is assigned.

If the allocation was successful, all allocated memory is guaranteed to be
completely zeroed out.

The target register must be a pointer, a reference, or a vector.

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

The source register must be a pointer, a reference, an array, or a vector.

mem.salloc
----------

**Has target register**
    Yes
**Source registers**
    1
**Operand type**
    None

Similar to mem.alloc_. This instruction, however, allocates the memory on the
stack. This means that memory allocated with this instruction shall not be
freed manually with mem.free_, as the code generator inserts cleanup code
automatically.

The target register must be a pointer.

mem.snew
--------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    None

Similar to mem.new_. This instruction, however, allocates the memory on the
stack. This means that memory allocated with this instruction shall not be
freed manually with mem.free_, as the code generator inserts cleanup code
automatically.

mem.pin
-------

**Has target register**
    Yes
**Source registers**
    1
**Operand type**
    None

Pins a reference previously allocated with mem.new_ or mem.alloc_ so that
the object it points to cannot be relocated by a compacting GC. This is
useful when calling into external code via ffi_, as the GC cannot track
GC-managed memory beyond managed code. This also implies that the memory
which is pinned will never be collected until it is unpinned. Therefore,
memory leaks can happen if care is not taken to correctly mem.unpin_ the
memory.

Passing a null pointer to this instruction results in undefined behavior.
The resulting value of this instruction is an opaque handle which only has
meaning to the specific GC implementation. The handle is intended for use
with mem.unpin_ later.

The source register must be a reference, an array, or a vector.

The target register must be of type ``uint``.

mem.unpin
---------

**Has target register**
    No
**Source registers**
    1
**Operand type**
    None

Unpins memory previously pinned with mem.pin_. The source register must be
a handle returned by mem.pin_. Any invalid handle value will result in
undefined behavior.

Care should be taken to only unpin the memory once it is certain that the
memory is no longer referenced outside managed code.

Memory aliasing instructions
++++++++++++++++++++++++++++

These instructions can be used for general pointer manipulation, such as
dereferencing, setting memory values, etc.

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

If the dereference operation failed in some way (e.g. the source pointer is
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

These instructions are used to index into and manipulate arrays and
vectors.

array.get
---------

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Fetches the value at the index given in the second source register from
the array given in the first source register and assigns it to the target
register. The first source register must be an array or vector type, while
the second register must be of type ``uint``.

The target register must be of the first source register's element type.

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
the second register must be of type ``uint``. The third register must be of
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
type, while the second source register must be of type ``uint``.

The target register must be a pointer to the first source register's element
type.

array.len
---------

**Has target register**
    Yes
**Source registers**
    1
**Operand type**
    None

Loads the length of an array into the target register. For arrays, this is
the dynamic size, while for vectors, it is the fixed size. The source
register must be an array or a vector.

The target register must be of type ``uint``.

Structure field instructions
++++++++++++++++++++++++++++

These instructions are used to operate on fields contained in structures
types and pointers to them.

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
source register must either be a structure or a pointer or reference to a
structure with at most one indirection.

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
The first source register must be a structure or a pointer or reference
to a structure with a most one indirection. The second source register
must match the field's type.

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
register must be a structure or a pointer or reference to a structure with
at most one indirection.

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

These instructions test relativity of their source registers.

cmp.eq
------

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Compares the two source registers for equality. If they are equal, the
target register is set to 1; otherwise, 0.

The source registers must be of the exact same type, and can be one of
``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``,
``int64``, ``uint64``, ``int``, ``uint``, ``float32``, ``float64``, or any
pointer type (in which case the pointers are compared for equality).
Vectors of these types are also allowed; they are compared
element-by-element and are considered equal if all elements are equal.

The target register must be of type `uint`, or a vector of `uint` (with
the same amount of elements as the source vectors) if the comparison
involved vectors.

cmp.neq
-------

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Compares the two source registers for inequality. If they are unequal, the
target register is set to 1; otherwise, 0.

The source registers must be of the exact same type, and can be one of
``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``,
``int64``, ``uint64``, ``int``, ``uint``, ``float32``, ``float64``, or any
pointer type (in which case the pointers are compared for equality).
Vectors of these types are also allowed; they are compared
element-by-element and are considered unequal if all elements are unequal.

The target register must be of type `uint`, or a vector of `uint` (with
the same amount of elements as the source vectors) if the comparison
involved vectors.

cmp.gt
------

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Determines if the value in the first source register is greater than the
value in the second source register. If this is true, the target register
is set to 1; otherwise, 0.

The source registers must be of the exact same type, and can be one of
``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``,
``int64``, ``uint64``, ``int``, ``uint``, ``float32``, ``float64``, or any
pointer type (in which case the pointers are compared). Vectors of these
types are also allowed; they are compared element-by-element and the first
vector is considered greater than the second vector if all elements are
greater.

The target register must be of type `uint`, or a vector of `uint` (with
the same amount of elements as the source vectors) if the comparison
involved vectors.

cmp.lt
------

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Determines if the value in the first source register is lesser than the
value in the second source register. If this is true, the target register
is set to 1; otherwise, 0.

The source registers must be of the exact same type, and can be one of
``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``,
``int64``, ``uint64``, ``int``, ``uint``, ``float32``, ``float64``, or any
pointer type (in which case the pointers are compared). Vectors of these
types are also allowed; they are compared element-by-element and the first
vector is considered lesser than the second vector if all elements are
lesser.

The target register must be of type `uint`, or a vector of `uint` (with
the same amount of elements as the source vectors) if the comparison
involved vectors.

cmp.gteq
--------

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Determines if the value in the first source register is greater than or
equal to the value in the second source register. If this is true, the
target register is set to 1; otherwise, 0.

The source registers must be of the exact same type, and can be one of
``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``,
``int64``, ``uint64``, ``int``, ``uint``, ``float32``, ``float64``, or any
pointer type (in which case the pointers are compared). Vectors of these
types are also allowed; they are compared element-by-element and the first
vector is considered greater than or equal to the second vector if all
elements are greater or equal.

The target register must be of type `uint`, or a vector of `uint` (with
the same amount of elements as the source vectors) if the comparison
involved vectors.

cmp.lteq
--------

**Has target register**
    Yes
**Source registers**
    2
**Operand type**
    None

Determines if the value in the first source register is lesser than or
equal to the value in the second source register. If this is true, the
target register is set to 1; otherwise, 0.

The source registers must be of the exact same type, and can be one of
``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``,
``int64``, ``uint64``, ``int``, ``uint``, ``float32``, ``float64``, or any
pointer type (in which case the pointers are compared). Vectors of these
types are also allowed; they are compared element-by-element and the first
vector is considered lesser than or equal to the second vector if all
elements are lesser or equal.

The target register must be of type `uint`, or a vector of `uint` (with
the same amount of elements as the source vectors) if the comparison
involved vectors.

Function invocation instructions
++++++++++++++++++++++++++++++++

These instructions are used to call functions and function pointers.

arg.push
--------

**Has target register**
    No
**Source registers**
    1
**Operand type**
    None

Enqueues the value in the source register into the functiona call argument
queue. The type of the value must equal the type of the function parameter
at the same index as this instruction.

This instruction must be immediately followed by another arg.push_ or any
of call_, call.tail_, call.indirect_, invoke_, invoke.tail_, or
invoke.indirect_.

arg.pop
-------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    None

Dequeues an argument given to a function. This instruction can only appear
in the "entry" basic block of a function, and must either be the first
instruction or come right after a previous arg.pop.

The target register must match the type of the function parameter at the
same index as this instruction.

call
----

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    Function reference

This performs a call to the function given as operand. This instruction
expects that the function has a return type (i.e. it does not return
``void``).

This instruction should follow immediately after a correct sequence of
arg.push_ instructions.

The result (as returned by the called function) is assigned to the target
register.

call.tail
---------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    Function reference

Works exactly like a call_, except that this instruction hints to the code
generator that tail call optimization should be done, if possible.

call.indirect
-------------

**Has target register**
    Yes
**Source registers**
    1
**Operand type**
    None

Performs a function call like the call_ instruction, but indirectly. The
source register must be a function pointer to a function returning
non-``void``, and the this instruction must (like call_) be immediately
preceeded by a correct arg.push_ sequence matching the function pointer's
signature.

The result of the call is assigned to the target register.

invoke
------

**Has target register**
    No
**Source registers**
    0
**Operand type**
    Function reference

This instruction does the same thing as call_, but only works for functions
with no return type (i.e. returning ``void``), and thus has no target
register.

invoke.tail
-----------

**Has target register**
    No
**Source registers**
    0
**Operand type**
    Function reference

This instruction does the same thing as call.tail_, but only works for
functions with no return type (i.e. returning ``void``), and thus has no
target register.

invoke.indirect
---------------

**Has target register**
    No
**Source registers**
    1
**Operand type**
    None

This instruction does the same thing as call.indirect_, but only works for
function pointers with no return type (i.e. returning ``void``), and thus
has no target register.

Control flow instructions
+++++++++++++++++++++++++

These instructions are used to transfer control from one point in a program
to another. Most are generally terminator instructions.

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

jump.cond
---------

**Has target register**
    No
**Source registers**
    1
**Operand type**
    Branch selector

Performs a jump to the first basic block if the value in the source
register (which must be of type ``uint``) does not equal 0; otherwise,
jumps to the second basic block.

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
the function returns ``void`` (or, in other words, has no return type).

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
``void`` (i.e. have a return type).

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
not appear in code passed to the interpreter or JIT/AOT engines.

The target register and selector registers must all be of the same type.

Note that this instruction doesn't count as a control flow instruction.
That is to say, multiple phi instructions are allowed in a basic block
while in SSA form, and they do not act as terminators.

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
This must be the only instruction in a raw function.

This instruction has a number of consequences:

* The function cannot be pure.
* The function cannot be inlined.
* All optimizations that would affect the layout of the stack cannot happen.
* Execution of the function within the interpreter becomes impossible.
* It must be the only instruction in the function.

Of course, usage of this instruction results in unportable code.

This instruction is primarily intended to allow the implementation of
inline assembly in high-level languages. While it doesn't give a clear way
to access IAL registers, the MCI ABI guarantees a well-defined layout of
locals and arguments on the stack when this instruction is present.

It should be noted that this is not sufficient to implement full-blown
inline assembly as in many C and C++ compilers. A general requirement of
inline assembly using this instruction is that the raw blob must contain
code that is neutral to relocations, as it is not in any way guaranteed
where the code blob will be emitted in memory.

This is a terminator instruction.

ffi
---

**Has target register**
    No
**Source registers**
    0
**Operand type**
    FFI signature

This instruction marks the function as an FFI function. FFI functions must
only contain this one instruction, which points the code generator to the
actual function entry point in a native library.

When using this instruction, a function cannot be pure and is not allowed
to be inlined.

Note that the native function isn't linked to statically. The execution
engine (either the interpreter or the JIT/AOT engine) will attempt to
locate the native entry point when the FFI function is called.

This is a terminator instruction.

Exception handling instructions
+++++++++++++++++++++++++++++++

eh.throw
--------

**Has target register**
    No
**Source registers**
    1
**Operand type**
    None

Throws an exception. This causes the runtime to unwind the stack until an
appropriate unwind block is found. If an unwind block is found, control
transfers to that block. If none is found, the program is terminated.

The source register must be a reference.

This is a terminator instruction.

eh.rethrow
----------

**Has target register**
    No
**Source registers**
    0
**Operand type**
    None

Rethrows an in-flight exception. This is different from using ``eh.throw``
to rethrow an exception reference in that this instruction does not reset
the stack trace.

This instruction may only appear in unwind blocks.

This is a terminator instruction.

eh.catch
--------

**Has target register**
    Yes
**Source registers**
    0
**Operand type**
    None

This catches the current in-flight exception and assigns it to the target
register. Note that this is not type-safe; it's similar to casting one
reference type to another with ``conv``. In order to determine the exact
exception type, language/ABI-specific checks must be made.

The target register must be a reference.

This instruction may only appear in unwind blocks.

Miscellaneous instructions
++++++++++++++++++++++++++

Instructions that don't quite fit anywhere else.

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

The following conversions are valid:

* ``T`` -> ``U`` for any primitives ``T`` and ``U`` (``int8``, ``uint8``,
  ``int16``, ``uint16``, ``int32``, ``uint32``, ``int64``, ``uint64``,
  ``int``, ``uint``, ``float32``, and ``float64``).
* ``T*`` -> ``U*`` for any ``T`` and any ``U``.
* ``T*`` -> ``uint`` or ``int`` for any ``T``.
* ``uint`` or ``int`` -> ``T*`` for any ``T``.
* ``T&`` -> ``U&`` for any ``T`` and any ``U``.
* ``T[E]`` -> ``U[E]`` for any valid ``T`` -> ``U`` conversion.
* ``R1(T1, ...)`` -> ``R2(U1, ...)`` for any ``R1``, any ``R2``, and any
  amount and type of ``T`` \ :sub:`n` and ``U`` \ :sub:`m`.
* ``R(T1, ...)`` -> ``U*`` for any ``R``, any amount and type of ``T``
  \ :sub:`n`, and any ``U``.
* ``T*`` -> ``R(U1, ...)`` for any ``T``, any ``R``, and any amount and
  type of ``U``\ :sub:`n`.
