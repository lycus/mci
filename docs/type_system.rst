Type system
===========

The MCI usus a strongly typed, nominal type system (although there is no
support for OO-like sub-typing). The type system consists of the following
categories of types:

* Primitive types: Integer and floating-point types (``int32``, ``int64``,
  ``float32``, ``float64``, etc).
* Structure types: Similar to ``struct``\ s in C.
* Type specifications: These are said to have one or more "element types".

  - Pointer types: Ye olde ``int32*`` and so on.
  - Reference types: Similar to pointers, but can only refer to structure
    types, and may only have one indirection (for example, ``Foo&``).
  - Array types: Simple one-dimensional arrays with a dynamic length (for
    example, ``float64[]``).
  - Vector types: Similar to arrays, but they have a fixed, static length
    (i.e. ``float64[3]``).
  - Function pointer types: These point to a function which can be invoked
    indirectly. They contain a calling convention, return type and parameter
    types (for example, ``int32(float32, float64)`` would be a pointer to a
    function taking a ``float32`` and a ``float64`` argument, returning
    ``int32``).

The following notation is used:

==================== ===============================================================
Notation             Meaning
==================== ===============================================================
``T``                Type name.
``T[]``              Array of ``T``.
``T[E]``             Vector of ``T`` with ``E`` elements.
``T*``               Pointer to ``T``.
``T&``               Reference to ``T``.
``R(T1, ...)``       Function pointer returning ``R``, taking ``T1``, ... arguments.
``R(T1, ...) cdecl`` Function pointer with ``cdecl`` calling convention.
==================== ===============================================================

Primitive types
+++++++++++++++

These are the building blocks of any application; they are the most basic
data types and represent integers and floating-point values. The following
primitive types exist:

* ``int8``: 8-bit signed integer.
* ``uint8``: 8-bit unsigned integer.
* ``int16``: 16-bit signed integer.
* ``uint16``: 16-bit unsigned integer.
* ``int32``: 32-bit signed integer.
* ``uint32``: 32-bit unsigned integer.
* ``int64``: 64-bit signed integer.
* ``uint64``: 64-bit unsigned integer.
* ``int``: Native-size signed integer (32-bit or 64-bit).
* ``uint``: Native-size unsigned integer (32-bit or 64-bit).
* ``float32``: 32-bit IEEE 754 floating-point value.
* ``float64``: 64-bit IEEE 754 floating-point value.

The fixed-width integers and floating-point types are guaranteed to be the
same size on all platforms. ``int`` and ``uint`` will be 32 or 64 bits wide
depending on the pointer length on the platform.

All primitives are convertible to/from each other.

Structure types
+++++++++++++++

A structure is a record that encapsulates a fixed number of fields, each of
their own type. A field consists of a storage class, a type, and a name.

Examples::

    // A structure with two instance fields. These can be accessed on any
    // instance of Foo, both as a value instance or as a pointer with one
    // indirection.
    type Foo
    {
        field instance int32 bar;
        field instance float64 baz;
    }

    // A structure with a static field. The field does not contribute to the
    // structure's size in memory, and cannot be accessed on an instance of
    // the structure.
    type Foo2
    {
        field static int32 bar;
    }

    // A type with a thread-local field. The field has distinct values for
    // each running thread in the program. Thread-local fields are similar
    // to static fields in that ``field.gset`` and related instructions must
    // be used to access them.
    type Foo3
    {
        field thread int32 bar;
    }

A structure can also specify its alignment (this is normally decided by the
compiler). The alignment must either be zero or a power of two. If it is
zero, the compiler picks the alignment (that is to say, zero is like the
default). Examples::

    // Use automatic alignment.
    type Foo3 align 0
    {
    }

    // Align fields sequentially.
    type Foo4 align 1
    {
    }

    // Align fields on a boundary of 16 bytes.
    type Foo5 align 16
    {
    }

Structures can be created in several ways:

* On the stack as a value: Simply declare a register typed as the structure.
  This makes it live on the stack with value semantics, and it will not
  participate in any kind of dynamic memory allocation.
* On the stack, dynamically allocated: Declare a register as a pointer to
  the structure and allocate the memory with ``mem.salloc`` or ``mem.snew``.
* On the heap, dynamically allocated: Declare a register as either a pointer
  to the structure, or as a vector or array of the structure. Then, allocate
  memory with ``mem.alloc`` or ``mem.new``.
* On the heap, GC-tracked: Declare a register as a reference to the structure
  and allocate an instance with ``mem.gcnew``. Additionally, references can
  be contained in vectors and arrays, and in other GC-tracked structures.

Type specifications
+++++++++++++++++++

Type specifications are types that contain or encapsulate other types, such
as pointers, arrays, vectors, etc.

Pointer types
-------------

A pointer is, semantically, just a native-size integer pointing to some
location in memory where the real value is. A pointer can point to any
other type (including pointers, resulting in several indirections).

Examples:

* Pointer to ``int32``: ``int32*``
* Pointer to array of ``float32``: ``float32[]*``
* Pointer to pointer to ``uint``: ``uint**``

Pointers are convertible to any other pointer type (including function
pointers) and the primitives ``int`` and ``uint``.

Reference types
---------------

References are similar to pointers, but are tracked by the GC (vectors
and arrays are also references, but this is implicit).

Examples:

* Reference to a struct called Foo: ``Foo&``

Any reference-to-reference conversion is valid.

Array types
-----------

These are single-dimensional, length-aware collections of elements. The
exact start and end of an array in memory is undefined, but all elements
are guaranteed to be laid out contiguously. In other words, an array can
be iterated by fetching the address of the first element and incrementing
the pointer.

Reading beyond the bounds of an array results in undefined behavior.

Arrays can only be allocated as GC-tracked objects.

Examples:

* Array of ``int32``: ``int32[]``
* Array of pointers to ``float64``: ``float64*[]``
* Array of arrays of ``int8``: ``int8[][]``

Any array-to-array conversion is valid as long as the source array's element
type is convertible to the target array's element type.

Vector types
------------

Vectors are similar to arrays in that they contain a series of contiguous
elements. Vectors, however, have a fixed, static length. This makes them
very easy to use with vectorization technology such as SIMD, as the JIT
compiler can unroll the SIMD operations statically.

Reading beyond the bounds of a vector results in undefined behavior.

Vectors, unlike arrays, have certain alignment requirements due to most
SIMD hardware. Usually, the first element will be aligned on either a
8-byte, 16-byte, or 32-byte boundary, although the exact alignment is
undefined. As with arrays, this means that the first element's address must
be fetched in order to iterate a vector in memory.

Vectors can only be allocated as GC-tracked objects.

Examples:

* Vector of ``int32`` with 3 elements: ``int32[3]``
* Vector of pointers to ``int32`` with 64 elements: ``int32[64]``
* Vector of 3 vectors of ``int32`` with 8 elements: ``int32[8][3]``

Any vector-to-vector conversion is valid as long as the two vectors have an
equal element count and the source vector's element type is convertible to
the target vector's element type.

Function pointer types
----------------------

These are simply pointers to functions in memory. A function pointer
carries information about the calling convention, return type, and
parameter types. Calling convention is optional; if it is not specified,
the default IAL calling convention is assumed.

Equality between function pointers pointing to the same function is
guaranteed if the function pointers are loaded using ``load.func``. All
other guarantees are up to the operating system the code is running on.

Examples:

* Function returning ``int32``, taking no parameters: ``int32()``
* Function returning ``void`` (i.e. nothing), taking ``float32``:
  ``void(float32)``
* Function returning ``void``, taking ``float32`` and ``int32``:
  ``void(float32, int32)``
* Function returning ``void``, taking no parameters, with ``cdecl`` calling
  convention: ``void() cdecl``

Function pointers are convertible to any pointer type.
