Type system
===========

The MCI usus a mostly strong, nominal type system. The type system consists of
the following categories of types:

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
  - Static array types: Similar to vectors, but live 'in place' where they
    are used (i.e. in a structure or a register). For example, ``int{3}``.
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
``T{E}``             Static array of ``T`` with ``E`` elements.
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
depending on the pointer length of the platform.

All primitives are convertible to/from each other.

Structure types
+++++++++++++++

A structure is a record that encapsulates a fixed number of fields, each of
their own type. A field consists of a type and a name.

Examples::

    // A structure with two instance fields. These can be accessed on any
    // instance of Foo, both as a value instance or as a pointer with one
    // indirection.
    type Foo
    {
        field int32 bar;
        field float64 baz;
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
  and allocate an instance with ``mem.new``. Additionally, references can
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

It is important to note that a reference value must be aligned on a native
word-size boundary. For example, this is problematic::

    type BadAlign align 1
    {
        field uint8 a;

        // This field will now be unaligned. This is undefined behavior.
        field BadAlign& b;
    }

Care should be taken when using an explicit alignment specification on
structures that contain references. The MCI's garbage collector, optimizer,
and code generator all assume that reference fields are aligned.

In addition to this rule, the object that the reference points to must be on
a native word-size boundary as well. This is less important to users, as the
``mem.new`` instruction guarantees this.

Structures instantiated on the GC heap are prefixed by a header (which is
implementation-defined) containing type information, GC bits, and so on. This
header also has a dedicated native word-sized field that can be accessed with
``field.user.set`` and related instructions. This field is primarily intended
for letting compilers assign language-specific type information to objects.

Examples of references:

* Reference to a struct called Foo: ``Foo&``

Any reference-to-reference conversion is valid, including reference-to-array
and reference-to-vector conversions.

Array types
-----------

These are single-dimensional, length-aware collections of elements. The
exact start and end of an array in memory is undefined, but all elements
are guaranteed to be laid out contiguously. In other words, an array can
be iterated by fetching the address of the first element and incrementing
the pointer.

The elements of an array are guaranteed to start at a boundary suitable for
SIMD operations on the machine. This typically means on an 8-byte, 16-byte, or
32-byte boundary, depending on the architecture (and the target machine's
detected features). The exact alignment should, for all practical purposes, be
considered undefined, however.

Reading beyond the bounds of an array results in undefined behavior.

Arrays can only be allocated as GC-tracked objects.

Examples:

* Array of ``int32``: ``int32[]``
* Array of pointers to ``float64``: ``float64*[]``
* Array of arrays of ``int8``: ``int8[][]``

Any array-to-array/vector conversion is valid as long as the source array's
element type is convertible to the target array/vector's element type.

Vector types
------------

Vectors are similar to arrays in that they contain a series of contiguous
elements. Vectors, however, have a fixed, static length. This makes them
very easy to use with vectorization technology such as SIMD, as the JIT
compiler can unroll the SIMD operations statically.

Reading beyond the bounds of a vector results in undefined behavior.

Vectors can only be allocated as GC-tracked objects.

Examples:

* Vector of ``int32`` with 3 elements: ``int32[3]``
* Vector of pointers to ``int32`` with 64 elements: ``int32*[64]``
* Vector of 3 vectors of ``int32`` with 8 elements: ``int32[8][3]``

Any vector-to-vector/array conversion is valid as long as the source vector's
element type is convertible to the target vector/array's element type.

Static array types
------------------

Static arrays are similar to vectors with the difference that they are stored
'in place'. That is, if a field in a structure is typed to be a static array,
that array's elements will be embedded directly in the structure. A register
typed to be a static array will also result in the the entire array being on
the stack.

Static arrays are, like arrays and vectors, guaranteed to be suitably aligned
for SIMD operations on the machine.

Static arrays are passed by value. This is unlike the C calling convention
where they are passed by reference. The same behavior can be achieved by
simply passing pointers to static arrays.

Examples:

* Static array of ``int32`` with 3 elements: ``int32{3}``
* Static array of pointers to ``int32`` with 64 elements: ``int32*{64}``
* Static array of 3 static arrays of ``int32`` with 8 elements: ``int32{8}{3}``

Static arrays cannot be converted to any other type.

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

Function pointers are convertible to any pointer type (including other
function pointer types).
