Garbage collection
==================

This page details the standardized garbage collection infrastructure that the
MCI provides to all programs running under the virtual machine.

Memory layout
+++++++++++++

All managed objects follow well-defined rules for physical layout of their
contents.

All objects start with an object header. After the header comes the contents
of the object. If the object is an array, the first thing after the header
will be the size field, which is exactly one machine word long. After that
comes whatever padding is needed to align elements to the native SSE boundary.
Following the padding are elements of the array, laid out contiguously. For
vectors, the layout is exactly the same, except for the lack of a size field
since the size is statically known (in other words, the padding space will
likely be larger for vectors on some platforms). For plain structure objects,
the fields follow immediately after the header.

Object headers
--------------

All managed objects contain a header that is exactly three machine words long.
This header contains type information, garbage collector bits, and the field
for user header data.

The specific layout is as follows:

====================== =========================================================================
Offset (32-bit/64-bit) Description
====================== =========================================================================
0/0                    Contains the type information pointer.
4/8                    Contains garbage collection bits (meaning specific to GC implementation).
8/16                   Contains the user data reference.
====================== =========================================================================

The type information pointer points to a structure that has a pointer to the
actual ``Type`` object, a cached size, and a computed reference layout bitmap.

Generally, the raw header is not accessible to managed code at all. Reliance
on the layout described here should be avoided except when consuming managed
objects in native code.

Reference bitmaps
-----------------

Most of the GC implementations use so-called reference layout bitmaps. These
are very compact descriptions of where in a managed object references might be
located. This information is useful to facilitate precise heap scanning.

Consider a type like this::

    type Foo
    {
        field instance Bar& bar;
        field instance int32 i;
        field instance float64 f;
        field instance Baz[] baz;
    }

From this definition, it is clear that we do not need to scan the memory area
consisting of ``i`` and ``f`` since they will never hold managed references.
We encode this information in a bitmap where each bit represents a word of the
type's memory layout. A 1 indicates that the word may hold a managed reference
if non-null, while 0 indicates that it is just plain data.

The bitmap for ``Foo`` as defined above would be, on a 32-bit system::

    00110001

On a 64-bit system::

    0011001

The first three bits are always 001 because they represent the object header
as described earlier. In the header, only the third field may hold a managed
reference. After the header comes the ``bar`` field which is clearly managed.
Next, we have two fields of plain data. Here is where the bitmap will differ
depending on bitness; on a 32-bit system, there will be three words between
``bar`` and ``baz`` - one for ``i`` and two for ``f``, while on a 64-bit
system, there will only be two words - one for ``i`` and one for ``f``. Due
to alignment, an extra 4 bytes are added after ``i``. Lastly, we have ``baz``
which is also clearly a managed reference.

The bitmap scheme works well regardless of the specific alignment imposed on
a type by the programmer because references are required to always sit on word
boundaries for correctness.

Note that the bitmap scheme is not currently used for arrays and vectors. In
practice, this only matters for conservative GCs (they may pick up false
pointers in arrays and vectors).

Reachability
++++++++++++

An object is considered garbage when it is no longer reachable, directly or
indirectly, from any GC roots (this includes stacks and registers). In the
heap (that is, inside allocated objects), only direct pointers to other
objects are considered. In stacks, interior pointers are allowed (this is to
facilitate passing object fields by reference).

Roots and ranges
----------------

Roots are single-word slots where the GC starts its scanning. A range is
simply a contiguous sequence of such slots. Conceptually, all thread stacks
are root ranges while global and TLS fields and machine registers are root
slots. Root slots are required to be exactly one machine word because that's
the size of a managed reference.

In addition to global and TLS fields, machine registers, and thread stacks,
internal objects managed by the virtual machine may also be registered as
roots.

Type precision
--------------

Since the MCI's type system is designed to fully support type-precise garbage
collection, most GC implementations use some kind of type information to
precisely identify managed references (typically bitmaps). This means that,
for example, an integer cannot appear to be a valid managed reference and thus
keep a managed object alive even though it is actually garbage.

Only the heap is scanned precisely in most GCs; roots and stacks are still
scanned conservatively in all GCs. This may change in the future if we decide
to compute precise stack maps, but this doesn't appear to be worth the effort
and time/space cost currently.

Weak references
---------------

There is support for weak references in all garbage collectors the MCI
provides. They are manipulated through the ``create_weak``,
``get_weak_target``, and ``set_weak_target`` intrinsics and are based on the
``Weak`` intrinsic type which is given special treatment by the virtual
machine. The object a weak reference points to can be collected if there are
no direct references to it other than through weak references. This can be
useful for caching mechanisms in particular.

It is not actually guaranteed whether the target of a weak reference will be
collected at all. Some garbage collectors may choose to treat weak references
as strong references if absolutely necessary.

Compaction and copying
++++++++++++++++++++++

Garbage collectors may use so-called moving collection techniques. There are
generally two forms of these: Compacting and copying. Both attempt to reduce
heap fragmentation. Compaction does so by moving live objects while doing a
collection. Copying uses two semispaces of equal size where live objects are
copied to/from on each collection (this halves the heap space, but requires
less passes over the heap than compaction).

The possible presence of these algorithms means that code must not assume that
objects are fixed at a certain location in memory. The MCI's type system and
ISA both try to enforce this by design (there are ways around this, but doing
so is not supported in any way).

Pinning
-------

The fact that objects may move arbitrarily means that native code can have
trouble working with them. Since the MCI has no knowledge of external native
code, it cannot correctly update references. The solution to this problem is
called pinning: A pinned object cannot be collected. The MCI provides the
``mem.pin`` and ``mem.unpin`` instructions to do this.

Pinning of objects passed to ``ffi`` calls is required for correct results.
This isn't statically verified, however, so undefined behavior can occur if
pinning is not done (usually, this just results in bad memory accesses in the
native code).

Practically, any object reachable directly from a root is pinned. However,
this is not at all guaranteed, so pinning is still required for correct code.

It's important that objects be unpinned once pinning is no longer required. If
an object is never unpinned, it will never be collected (until application
shutdown).

Finalization
++++++++++++

It is possible to register finalizers for all managed objects (including
arrays and vectors). The ``gc_set_free_callback`` intrinsic registers a
callback for a specific object. This callback will be called when the object
is no longer reachable from any live object regardless of cycles (i.e. the
finalizable object is reachable directly or indirectly from itself). Passing a
null callback to ``gc_add_free_callback`` will remove any callback registered
for the given object. Note that a callback is automatically removed before it
is run.

No particular order of finalization is guaranteed. Callbacks should be
programmed to not rely on order at all. Additionally, it is not guaranteed
what thread a finalizer will run on, but it is guaranteed that the world will
be resumed by the time a finalizer callback runs.

The ``gc_wait_for_free_callbacks`` intrinsic will block the calling thread
until all queued finalization callbacks have been called. It can be useful
if one needs to wait for a particular set of objects' finalization callbacks
to run before continuing execution. Generally, this is achieved by letting
those objects become garbage, calling ``gc_collect``, and finally calling
``gc_wait_for_free_callbacks``.

Barriers
++++++++

Garbage collectors may require the use of read/write barriers. Contrary to
what this terminology may suggest, barriers don't necessarily have anything to
do with concurrency. They can be used for a wide array of things, and the
specific purpose depends entirely on the GC implementation.

Barriers come in three flavors: Field reads/writes, array loads/stores, and
indirect memory loads/stores. All of these barrier types are only called when
managed types are involved. They are also only inserted into generated code
if the GC specifically asks for them to be inserted, so there is no speed cost
if a GC does not use barriers.

Garbage collectors
++++++++++++++++++

This section lists the current GC implementations available in the MCI.

D runtime garbage collector
---------------------------

**GC name**
    ``dgc``
**Type precision**
    Conservative
**Supports finalization**
    No
**Is generational**
    No
**Is incremental**
    No
**Is moving**
    No
**Uses barriers**
    No

This GC uses druntime's built-in garbage collector implementation. It is
entirely conservative and makes no use of type information. It has no support
for finalization due to limitations in druntime.

This GC is reasonably fast, but is geared towards native languages running in
an uncooperative environment, and therefore doesn't make use of any of the
information available for free in the MCI.

This is a stop-the-world collector with no support for parallel/concurrent GC.

Boehm-Demers-Weiser garbage collector
-------------------------------------

**GC name**
    ``boehm``
**Type precision**
    Partially conservative
**Supports finalization**
    Yes
**Is generational**
    Optionally
**Is incremental**
    Optionally
**Is moving**
    No
**Uses barriers**
    No

This GC uses the Boehm-Demers-Weiser garbage collector (libgc). It has partial
support for precise scanning using type bitmaps (only for structure types).

This GC is highly tuned through more than two centuries of development. It
supports parallel marking and incremental collection.

This is a stop-the-world collector with no support for concurrent GC.

Note that this GC is not available on Windows. Also note that the MCI assumes
that it is the only user of libgc in the process it's running in, so it will
liberally set certain options without regarding any values they may have been
set to previously (and also assumes those options won't be changed).

LibC garbage collector
----------------------

**GC name**
    ``libc``
**Type precision**
    N/A
**Supports finalization**
    Yes
**Is generational**
    No
**Is incremental**
    No
**Is moving**
    No
**Uses barriers**
    No

This GC performs no actual collection; it is equivalent to a null GC. It
supports plain allocations and deallocations, and supports finalization (which
is only triggered on explicit deallocation).
