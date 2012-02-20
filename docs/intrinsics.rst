Intrinsics
==========

The MCI defines a number of built-in functions that can be called by any
program compiled with the infrastructure. These all reside in the ``mci``
module, which is actually implemented in D code inside the ``mci.vm``
library.

This module is given special treatment by the assembler, so you do not
need to provide a physical module that implements it.

Types
+++++

Object
------

This is an opaque type which is useful for representing an arbitrary
reference type::

    type Object
    {
    }

Configuration information
+++++++++++++++++++++++++

These intrinsics retrieve information about the environment the MCI was
compiled in.

mci_get_compiler
----------------

**Signature**
    ``uint8 mci_get_compiler()``

Gets a value indicating which compiler was used to build the MCI.

Possible values:

===== ========================
Value Description
===== ========================
0     Unknown compiler.
1     Digital Mars D (DMD).
2     GNU D Compiler (GDC).
3     LLVM D Compiler (LDC).
4     Stupid D Compiler (SDC).
===== ========================

mci_get_architecture
--------------------

**Signature**
    ``uint8 mci_get_architecture()``

Gets a value indicating which architecture the MCI was compiled for.

Possible values:

===== ===========================
Value Description
===== ===========================
0     x86 (32-bit or 64-bit).
1     ARM (32-bit).
2     PowerPC (32-bit or 64-bit).
3     Itanium (64-bit).
4     MIPS (32-bit or 64-bit).
===== ===========================

mci_get_operating_system
------------------------

**Signature**
    ``uint8 mci_get_operating_system()``

Gets a value indicating which operating system the MCI was compiled on.

Possible values:

===== ====================================
Value Description
===== ====================================
0     All Windows systems.
1     All Linux systems.
2     Mac OS X (and other Darwin systems).
3     All BSD systems.
4     FreeBSD.
5     OpenBSD.
6     Solaris.
7     AIX.
8     GNU Hurd.
===== ====================================

mci_get_endianness
------------------

**Signature**
    ``uint8 mci_get_endianness()``

Gets a value indicating which endianness the MCI was compiled for.

Possible values:

===== ==============
Value Description
===== ==============
0     Little endian.
1     Big endian.
===== ==============

mci_get_emulation_layer
-----------------------

**Signature**
    ``uint8 mci_get_emulation_layer()``

Gets a value indicating which emulation layer the MCI is compiled under.

Possible values:

===== ===================
Value Description
===== ===================
0     No emulation layer.
1     Cygwin.
2     MinGW.
===== ===================

mci_is_32_bit
-------------

**Signature**
    ``uint mci_is_32_bit()``

Gets a value indicating whether the MCI is compiled for 32-bit pointers.

This function returns 0 if the MCI is compiled for 64-bit pointers; 1 if
it's compiled for 32-bit pointers.

Atomic operations
+++++++++++++++++

Memory management
+++++++++++++++++

**Signature**
    ``uint mci_is_aligned(uint8*)``

Determines whether the given pointer is properly aligned for the system
the program is currently running on. Returns 1 if the pointer is properly
aligned; otherwise, returns 0.

Here, "properly aligned" usually means being a multiple of 4 or 8 depending
on the pointer length of the platform (32 and 64 bits, respectively).

**Signature**
    ``void mci_gc_collect()``

Instructs the GC to perform a full collection. This may cause a stop of the
world.

**Signature**
    ``void mci_gc_minimize()``

Instructs the GC to perform as much cleanup work as it can without stopping
the world.

**Signature**
    ``uint64 mci_gc_get_collections()``

Gets a value indicating the amount of collections the GC has performed.

**Signature**
    ``void mci_gc_add_pressure(uint)``

Informs the GC that a significant amount of unmanaged memory (given by the
argument) is about to be allocated.

**Signature**
    ``void mci_gc_remove_pressure(uint)``

Informs the GC that a significant amount of unmanaged memory (given by the
argument) is about to be freed.

**Signature**
    ``uint mci_gc_is_generational()``

Gets a value indicating whether the GC is generational.

**Signature**
    ``uint mci_get_generations()``

Gets the amount of generations managed by the GC. This is guaranteed to be a
constant number.

Calling this function if the GC is not generational results in undefined
behavior.

**Signature**
    ``void mci_gc_generation_collect(uint)``

Instructs the GC generation given by the ID in the argument to perform a full
collection. This may cause a stop of the world.

Calling this function if the GC is not generational results in undefined
behavior.

**Signature**
    ``void mci_gc_generation_minimize(uint)``

Instructs the GC generation given by the ID in the argument to perform as much
cleanup work as it can without stopping the world.

Calling this function if the GC is not generational results in undefined
behavior.

**Signature**
    ``uint mci_gc_generation_get_collections(uint)``

Gets a value indicating the amount of collections the GC has performed in the
generation given by the ID in the argument.

Calling this function if the GC is not generational results in undefined
behavior.

**Signature**
    ``uint mci_gc_is_interactive()``

Gets a value indicating whether the GC is interactive (i.e. supports allocate
and free callbacks). Returns 1 if the GC is interactive; otherwise, returns
0.

**Signature**
    ``void mci_gc_add_allocate_callback(void(Object&) cdecl)``

Adds a callback to the GC which will be called on every allocation made in
the program. The parameter given to the function pointer is the newly
allocated object. Note that the callback will be triggered right after the
memory has been allocated.

Calling this function if the GC is not interactive results in undefined
behavior.

**Signature**
    ``void mci_gc_add_free_callback(void(Object&) cdecl)``

Adds a callback to the GC which will be called on every freeing of memory
made in the program. The argument given to the function pointer is the freed
object. Note that the callback will be triggered just before the memory is
actually freed.

Calling this function if the GC is not interactive results in undefined
behavior.
