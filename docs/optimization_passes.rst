Optimization passes
===================

This page lists the optimization passes that the MCI supports.

Fast passes are those that are considered extremely fast at executing, while
slow passes are those that take a very long time to run. Moderate passes are
somewhere in between.

Unsafe passes are those that may actually alter the semantics of a program in
order to get better performance. In general, these should not be used unless
you *really* know what you're doing (a program typically has to be written
with these passes in mind in order to not break when they're used).

Note that some optimization passes only work in SSA form, while others only
work on non-SSA form. Some passes are form-agnostic.

Fast passes
+++++++++++

Unused register remover
-----------------------

**Pass name**
    ``unused-reg``
**IR type**
    Any

This is a very simple pass that simply removes all unused registers in a
function. This is completely harmless for the most part, but has the minor
side-effect that the stack layout of the function will be different once
unused registers are removed. Generally, programs should not rely on stack
layout in the first place, so it is safe to assume that this optimization is
always safe.

Running this pass after sparse conditional constant propagation and dead code
elimination is generally a good idea, since it cleans up the registers left
behind by those passes.

Unused basic block remover
--------------------------

**Pass name**
    ``unused-bb``
**IR type**
    Any

This pass removes all unused basic blocks in a function. A basic block is
considered unused if no branching instruction in the function targets it and
the basic block isn't set as the unwind block of any *other* basic blocks (if
the basic block has itself set as unwind block, it is considered unused).

Running this pass after sparse conditional constant propagation is generally a
good idea, since it cleans up the basic blocks left behind by that pass, which
can significantly reduce code size.

Constant folder
---------------

**Pass name**
    ``const-fold``
**IR type**
    SSA

This pass performs simple constant folding. This includes all binary operators
(like add, subtract, multiply, divide, and so on) except comparison operators.
In general, the pass only concerns itself with integers with a fixed size and
floating-point values. It doesn't attempt to optimize operations on native
integers. Note also that the pass stops folding if it encounters a division by
zero, since this usually means that a hardware trap must be generated at
runtime, rather than silently ignoring it at compile time.

This pass should in most cases be applied before any other passes.

Dead code eliminator
--------------------

**Pass name**
    ``dce``
**IR type**
    SSA

This is an agressive dead code elimination pass. It assumes that all of a
function's instructions are dead until proven otherwise.

Specifically, it starts out with a list of all 'root' instructions. These are
the instructions known to be live unconditionally. The pass currently assumes,
conservatively, that all instructions without a target register are live.
Further, instructions with target registers that have side-effects (such as
pinning a reference, allocating memory, and so on) are considered live. All
terminator instructions are considered live as well. This list of root
instructions is then used to propagate liveness backwards such that all of the
instructions that the root instructions depend on are also considered live.
Finally, the instructions that are not live are removed.

It's a good idea to run this after sparse conditional constant propagation to
clean up dead definitions.

Moderate passes
+++++++++++++++

Slow passes
+++++++++++

Unsafe passes
+++++++++++++
