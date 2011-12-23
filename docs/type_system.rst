Type system
===========

The MCI usus a strongly typed, nominal type system (although there is no
support for OO-like sub-typing). The type system consists of the following
categories of types:

* Primitive types: Integer and floating-point types (``int32``, ``int64``,
  ``float32``, ``float64``, etc).
* Structure types: Similar to ``struct``\ s and ``union``\ s in C.
* Type specifications: These are said to have one or more "element types".

  - Pointer types: Ye olde ``int32*`` and so on.
  - Array types: Simple one-dimensional arrays with a dynamic length (for
    example, ``float64[]``).
  - Vector types: Similar to arrays, but they have a fixed, static length
    (i.e. ``float64[3]``).
  - Function pointer types: These point to a function which can be invoked
    indirectly. They contain a return type and parameter types (for example,
    ``int32(float32, float64)`` would be a pointer to a function taking a
    ``float32`` and a ``float64`` argument, returning ``int32``).

The following notation is used:

================= ===============================================================
Notation          Meaning
================= ===============================================================
``T``             Type name.
``T[]``           Array of ``T``.
``T[E]``          Vector of ``T`` with ``E`` elements.
``T*``            Pointer to ``T``.
``R(T1, ...)``    Function pointer returning ``R``, taking ``T1``, ... arguments.
================= ===============================================================

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

A structure can also specify its alignment (this is normally decided by the
compiler). The alignment must be either be zero or a power of two. If it is
zero, the compiler picks the alignment (that is to say, zero is like the
default). Examples::

    // Use automatic alignment.
    type Foo3 (0)
    {
    }

    // Align fields sequentially.
    type Foo4 (1)
    {
    }

    // Align fields on a boundary of 16 bytes.
    type Foo5 (16)
    {
    }

Structures can be created in two ways:

* On the stack: Simply declare a register typed to be an instance of the
  structure. This makes it a value instance that lives on the stack (and
  thus does not participate in any dynamic memory allocation).
* On the heap: Allocate an instance with either ``mem.new`` or
  ``mem.gcnew``. This will result in a pointer to the instance which sits
  somewhere in either the native or managed heap.

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
pointers), as well as arrays of the element type, and the primitives
``int`` and ``uint``.

Array types
-----------

An array is very similar to a pointer in that it is semantically just
a pointer to a block of memory where the elements reside. Elements are
guaranteed to be contiguous in memory. Additionally, arrays don't know
their length.

Reading beyond the bounds of an array results in undefined behavior.

Examples:

* Array of ``int32``: ``int32[]``
* Array of pointers to ``float64``: ``float64*[]``
* Array of arrays of ``int8``: ``int8[][]``

Arrays are convertible to pointers to the element type.

Vector types
------------

Vectors are similar to arrays in that they contain a series of contiguous
elements. Vectors, however, have a fixed, static length. This makes them
very easy to use with vectorization technology such as SIMD.

Reading beyond the bounds of a vector results in undefined behavior.

It should be noted that, while vectors are similar to arrays, they are not
laid out in memory in the same way that arrays are. For vectors to be
useful in SIMD, their first element needs to be aligned correctly. On most
processors, this is on a 16-byte (128-bit) boundary, but can also be on an
8-byte (64-bit) and 32-byte (256-bit) boundary. This means that more memory
than what is strictly required might be allocated in order to satisfy such
alignment requirements. This also means that vectors don't point directly
to the first element (like arrays do), but rather to the beginning of the
entire memory block. In practice, this means that to get a pointer to the
vector that can be used to iterate its elements, one must retrieve the
address of the first element in the vector and use that.

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
carries information about the return type and parameter types.

Examples:

* Function returning ``int32``, taking no parameters: ``int32()``
* Function returning void (i.e. nothing), taking ``float32``:
  ``void(float32)``
* Function returning void, taking ``float32`` and ``int32``:
  ``void(float32, int32)``

Calling convention is not part of the function pointer type, but is
rather specified when invoking the function pointer.

Function pointers are convertible to any pointer type.
