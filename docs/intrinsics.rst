Intrinsics
==========

The MCI defines a number of built-in functions that can be called by any
program compiled with the infrastructure. These all reside in the ``mci``
module, which is actually implemented in D code inside the ``mci.vm``
library.

All intrinsics are thread safe.

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

Weak
----

This is an opaque wrapper type given special treatment by garbage collector
implementations that support it. It facilitates so-called weak references::

    type Weak
    {
    }

Instances of this type should not be manipulated directly. The layout of this
type is completely unspecified and any reliance on it is unsupported. To work
with instances of ``Weak``, use the related intrinsics.

Configuration information
+++++++++++++++++++++++++

These intrinsics retrieve information about the environment the MCI was
compiled in.

get_compiler
------------

**Signature**
    ``uint8 get_compiler()``

Gets a value indicating which compiler was used to build the MCI.

Possible values:

===== ========================
Value Description
===== ========================
0     Unknown compiler.
1     Digital Mars D (DMD).
2     GNU D Compiler (GDC).
3     LLVM D Compiler (LDC).
===== ========================

get_architecture
----------------

**Signature**
    ``uint8 get_architecture()``

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

get_operating_system
--------------------

**Signature**
    ``uint8 get_operating_system()``

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

get_endianness
--------------

**Signature**
    ``uint8 get_endianness()``

Gets a value indicating which endianness the MCI was compiled for.

Possible values:

===== ==============
Value Description
===== ==============
0     Little endian.
1     Big endian.
===== ==============

get_emulation_layer
-------------------

**Signature**
    ``uint8 get_emulation_layer()``

Gets a value indicating which emulation layer the MCI is compiled under.

Possible values:

===== ===================
Value Description
===== ===================
0     No emulation layer.
1     Cygwin.
2     MinGW.
===== ===================

is_32_bit
---------

**Signature**
    ``uint is_32_bit()``

Gets a value indicating whether the MCI is compiled for 32-bit pointers.

This function returns 0 if the MCI is compiled for 64-bit pointers; 1 if
it's compiled for 32-bit pointers.

Atomic operations
+++++++++++++++++

atomic_load
-----------

**Signature**
    ``Object& atomic_load(Object&*)``

Atomically loads the reference from the memory location pointed to by the
first argument.

atomic_store
------------

**Signature**
    ``void atomic_store(Object&*, Object&)``

Atomically sets the location pointed to by the first argument to the reference
in the second argument.

atomic_exchange
---------------

**Signature**
    ``uint atomic_exchange(Object&*, Object&, Object&)``

Stores the reference in the third argument to the location pointed to by
the first argument if the reference pointed to by the first argument is
equal to the second argument. All of this happens atomically.

Returns 1 if the store happened; otherwise, returns 0.

atomic_load_u
-------------

**Signature**
    ``uint atomic_load_u(uint*)``

Atomically loads the value from the memory location pointed to by the first
argument.

atomic_store_u
--------------

**Signature**
    ``void atomic_store_u(uint*, uint)``

Atomically sets the location pointed to by the first argument to the value in
the second argument.

atomic_exchange_u
-----------------

**Signature**
    ``uint atomic_exchange_u(uint*, uint, uint)``

Stores the value in the third argument to the location pointed to by the
first argument if the value pointed to by the first argument is equal to
the second argument. All of this happens atomically.

Returns 1 if the store happened; otherwise, returns 0.

atomic_add_u
------------

**Signature**
    ``uint atomic_add_u(uint*, uint)``

Atomically adds the value in the second argument to the value pointed to by
the first argument and returns the result.

The result is also assigned to the location pointed to by the first argument.

atomic_sub_u
------------

**Signature**
    ``uint atomic_sub_u(uint*, uint)``

Atomically subtracts the value in the second argument from the value pointed
to by the first argument and returns the result.

The result is also assigned to the location pointed to by the first argument.

atomic_mul_u
------------

**Signature**
    ``uint atomic_mul_u(uint*, uint)``

Atomically multiplies the value pointed to by the first argument with the
value in the second argument and returns the result.

The result is also assigned to the location pointed to by the first argument.

atomic_div_u
------------

**Signature**
    ``uint atomic_div_u(uint*, uint)``

Atomically divides the value pointed to by the first argument with the value
in the second argument and returns the result.

The result is also assigned to the location pointed to by the first argument.

atomic_rem_u
------------

**Signature**
    ``uint atomic_rem_u(uint*, uint)``

Atomically computes the remainder from dividing the value pointed to by the
first argument by the value in the second argument and returns the result.

The result is also assigned to the location pointed to by the first argument.

atomic_and_u
------------

**Signature**
    ``uint atomic_and_u(uint*, uint)``

Aotmically computes bit-wise AND between the value pointed to by the first
argument and the value in the second argument and return the result.

The result is also assigned to the location pointed to by the first argument.

atomic_or_u
-----------

**Signature**
    ``uint atomic_or_u(uint*, uint)``

Aotmically computes bit-wise OR between the value pointed to by the first
argument and the value in the second argument and return the result.

The result is also assigned to the location pointed to by the first argument.

atomic_xor_u
------------

**Signature**
    ``uint atomic_xor_u(uint*, uint)``

Aotmically computes bit-wise XOR between the value pointed to by the first
argument and the value in the second argument and return the result.

The result is also assigned to the location pointed to by the first argument.

atomic_load_s
-------------

**Signature**
    ``int atomic_load_s(int*)``

Atomically loads the value from the memory location pointed to by the first
argument.

atomic_store_s
--------------

**Signature**
    ``void atomic_store_s(int*, int)``

Atomically sets the location pointed to by the first argument to the value in
the second argument.

atomic_exchange_s
-----------------

**Signature**
    ``int atomic_exchange_s(int*. int, int)``

Stores the value in the third argument to the location pointed to by the
first argument if the value pointed to by the first argument is equal to
the second argument. All of this happens atomically.

Returns 1 if the store happened; otherwise, returns 0.

atomic_add_s
------------

**Signature**
    ``int atomic_add_s(int*, int)``

Atomically adds the value in the second argument to the value pointed to by
the first argument and returns the result.

The result is also assigned to the location pointed to by the first argument.

atomic_sub_s
------------

**Signature**
    ``int atomic_sub_s(int*, int)``

Atomically subtracts the value in the second argument from the value pointed
to by the first argument and returns the result.

The result is also assigned to the location pointed to by the first argument.

atomic_mul_s
------------

**Signature**
    ``int atomic_mul_s(int*, int)``

Atomically multiplies the value pointed to by the first argument with the
value in the second argument and returns the result.

The result is also assigned to the location pointed to by the first argument.

atomic_div_s
------------

**Signature**
    ``int atomic_div_s(int*, int)``

Atomically divides the value pointed to by the first argument with the value
in the second argument and returns the result.

The result is also assigned to the location pointed to by the first argument.

atomic_rem_s
------------

**Signature**
    ``int atomic_rem_s(int*, int)``

Atomically computes the remainder from dividing the value pointed to by the
first argument by the value in the second argument and returns the result.

The result is also assigned to the location pointed to by the first argument.

atomic_and_s
------------

**Signature**
    ``int atomic_and_s(int*, int)``

Aotmically computes bit-wise AND between the value pointed to by the first
argument and the value in the second argument and return the result.

The result is also assigned to the location pointed to by the first argument.

atomic_or_s
-----------

**Signature**
    ``int atomic_or_s(int*, int)``

Aotmically computes bit-wise OR between the value pointed to by the first
argument and the value in the second argument and return the result.

The result is also assigned to the location pointed to by the first argument.

atomic_xor_s
------------

**Signature**
    ``int atomic_xor_s(int*, int)``

Aotmically computes bit-wise XOR between the value pointed to by the first
argument and the value in the second argument and return the result.

The result is also assigned to the location pointed to by the first argument.

Memory management
+++++++++++++++++

gc_collect
----------

**Signature**
    ``void gc_collect()``

Instructs the GC to perform a full collection. This may cause a stop of the
world.

gc_minimize
-----------

**Signature**
    ``void gc_minimize()``

Instructs the GC to do minimal GC work. This function is appropriate for
tight loops, and is relatively cheap.

gc_get_collections
------------------

**Signature**
    ``uint64 gc_get_collections()``

Gets a value indicating the amount of collections the GC has performed.

gc_add_pressure
---------------

**Signature**
    ``void gc_add_pressure(uint)``

Informs the GC that a significant amount of unmanaged memory (given by the
argument) is about to be allocated.

gc_remove_pressure
------------------

**Signature**
    ``void gc_remove_pressure(uint)``

Informs the GC that a significant amount of unmanaged memory (given by the
argument) is about to be freed.

gc_is_generational
------------------

**Signature**
    ``uint gc_is_generational()``

Gets a value indicating whether the GC is generational.

gc_get_generations
------------------

**Signature**
    ``uint gc_get_generations()``

Gets the amount of generations managed by the GC. This is guaranteed to be a
constant number.

Calling this function if the GC is not generational results in undefined
behavior.

gc_generation_collect
---------------------

**Signature**
    ``void gc_generation_collect(uint)``

Instructs the GC generation given by the ID in the argument to perform a full
collection. This may cause a stop of the world.

Calling this function if the GC is not generational results in undefined
behavior.

gc_generation_minimize
----------------------

**Signature**
    ``void gc_generation_minimize(uint)``

Instructs the GC generation given by the ID in the argument to perform as much
cleanup work as it can without stopping the world.

Calling this function if the GC is not generational results in undefined
behavior.

gc_generation_get_collections
-----------------------------

**Signature**
    ``uint gc_generation_get_collections(uint)``

Gets a value indicating the amount of collections the GC has performed in the
generation given by the ID in the argument.

Calling this function if the GC is not generational results in undefined
behavior.

gc_is_interactive
-----------------

**Signature**
    ``uint gc_is_interactive()``

Gets a value indicating whether the GC is interactive (i.e. supports allocate
and free callbacks). Returns 1 if the GC is interactive; otherwise, returns
0.

gc_add_allocate_callback
------------------------

**Signature**
    ``void gc_add_allocate_callback(void(Object&) cdecl)``

Adds a callback to the GC which will be called on every allocation made in
the program. The parameter given to the function pointer is the newly
allocated object. Note that the callback will be triggered right after the
memory has been allocated.

Calling this function if the GC is not interactive or with a null callback
pointer results in undefined behavior.

gc_remove_allocate_callback
---------------------------

**Signature**
    ``void gc_remove_allocate_callback(void(Object&) cdecl)``

Removes a callback previously added with gc_add_allocate_callback_. If the
given callback was not registered previously, nothing happens.

Calling this function if the GC is not interactive or with a null callback
pointer results in undefined behavior.

gc_set_free_callback
--------------------

**Signature**
    ``void gc_set_free_callback(Object&, void(Object&) cdecl)``

Adds a callback to the GC which will be called on the given object when it is
no longer reachable (i.e. considered garbage). Note that this callback will be
triggered just before the memory is actually freed. Passing a null value as the
second argument will remove any existing callback for the given object. Passing
any other value when a callback is already registered simply overwrites the
existing callback.

The callback is automatically removed when the object is freed.

Calling this function if the GC is not interactive or with a null object results
in undefined behavior.

gc_wait_for_free_callbacks
--------------------------

**Signature**
    ``void gc_wait_for_free_callbacks()``

Blocks the current thread until all free callbacks that are currently enqueued
have been processed by the finalization thread.

gc_is_atomic
------------

**Signature**
    ``uint gc_is_atomic()``

Gets a value indicating whether the GC is atomic (i.e. requires read or write
barriers). Returns 1 if the GC is atomic; otherwise, returns 0.

gc_get_barriers
---------------

**Signature**
    ``uint8 gc_get_barriers()``

Returns flags indicating which barriers the current GC requires.

Possible flags:

===== ===============================================
0x00  No barriers are required.
0x01  Read barriers are required for fields.
0x02  Write barriers are required for fields.
0x04  Read barriers are required for array loads.
0x08  Write barriers are required for array stores.
0x10  Read barriers are required for indirect stores.
0x20  Write barriers are required for indirect loads.
===== ===============================================

Math and IEEE 754 operations
++++++++++++++++++++++++++++

nan_with_payload_f32
--------------------

**Signature**
    ``float32 nan_with_payload_f32(uint32)``

Produces a NaN (not a number) value with a given user payload. This abuses an
obscure feature of IEEE 754 that allows 22 bits of a NaN value to be set to a
user-specified value. This does of course mean that only 22 bits of the given
payload will be inserted in the NaN value.

nan_with_payload_f64
--------------------

**Signature**
    ``float64 nan_with_payload_f64(uint64)``

Produces a NaN (not a number) value with a given user payload. This abuses an
obscure feature of IEEE 754 that allows 51 bits of a NaN value to be set to a
user-specified value. This does of course mean that only 51 bits of the given
payload will be inserted in the NaN value.

nan_get_payload_f32
-------------------

**Signature**
    ``uint32 nan_get_payload_f32(float32)``

Extracts the 22-bit payload stored in a NaN (not a number) value.

nan_get_payload_f64
-------------------

**Signature**
    ``uint64 nan_get_payload_f64(float64)``

Extracts the 51-bit payload stored in a NaN (not a number) value.

is_nan_f32
----------

**Signature**
    ``uint is_nan_f32(float32)``

Returns 1 if the given value is NaN (not a number); otherwise, returns 0. This
function is payload-aware, so NaNs with payloads will correctly be regarded
NaN.

is_nan_f64
----------

**Signature**
    ``uint is_nan_f64(float64)``

Returns 1 if the given value is NaN (not a number); otherwise, returns 0. This
function is payload-aware, so NaNs with payloads will correctly be regarded
NaN.

is_inf_f32
----------

**Signature**
    ``uint is_inf_f32(float32)``

Returns 1 if the given value is positive or negative infinity; otherwise,
returns 0.

is_inf_f64
----------

**Signature**
    ``uint is_inf_f64(float64)``

Returns 1 if the given value is positive or negative infinity; otherwise,
returns 0.

Weak references
+++++++++++++++

create_weak
-----------

**Signature**
    ``Weak& create_weak(Object&)``

Creates a weak reference to an object given in the first parameter. Calling
this function with a null parameter results in undefined behavior.

This function returns null if insufficient memory is available. The weak
reference returned by this intrinsic must not be freed with ``mem.free`` or
any other deallocation mechanism.

get_weak_target
---------------

**Signature**
    ``Object& get_weak_target(Weak&)``

Gets the target of a given weak reference. Calling this function with a null
weak reference results in undefined behavior.

The returned object may be null, since the target of the weak reference could
have been collected since it was set.

set_weak_target
---------------

**Signature**
    ``void set_weak_target(Weak&, Object&)``

Sets the target of a given weak reference. Calling this function with a null
weak reference results in undefined behavior.
