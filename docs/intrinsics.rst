Intrinsics
==========

The MCI defines a number of built-in functions that can be called by any
program compiled with the infrastructure. These all reside in the ``mci``
module, which is actually implemented in D code inside the ``mci.vm``
library.

This module is given special treatment by the assembler, so you do not
need to provide a physical module that implements it.

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
