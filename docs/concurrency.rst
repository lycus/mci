Concurrency
===========

The virtual machine generally doesn't make many guarantees in a concurrent
environment. In general, managed code should not depend on atomicity
guarantees made by the underlying hardware, as this makes code unportable
in very subtle and hard-to-detect ways.

In other words, we do not guarantee that reads and writes of word-sized
values will be atomic, as many other virtual machines do. While, in
practice, you may find that they actually are (due to how the hardware
works), it is not something we guarantee, and MCI will not consider
atomicity of such operations when reordering instructions and performing
other such optimizations.

The one thing that the virtual machine does guarantee is the consistency of
reference values (this includes array and vector references). What this
means is that dereferencing a reference (or an array/vector) will never
result in an invalid memory access due to concurrency (save for the null
case, naturally). Note that this is only guaranteed for references that are
correctly aligned on a native word-size boundary.
