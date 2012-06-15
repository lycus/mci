module mci.vm.trace;

import mci.core.container,
       mci.core.code.instructions;

/**
 * Represents a managed stack trace. Can be used to
 * figure out the call stack of a program when an
 * exception is thrown.
 */
public final class StackTrace
{
    private NoNullList!StackFrame _frames;

    invariant()
    {
        assert(_frames);
        assert(!(cast()_frames).empty);
    }

    /**
     * Constructs a new $(D StackTrace) instance.
     *
     * Params:
     *  frames = The stack frames.
     */
    public this(NoNullList!StackFrame frames)
    in
    {
        assert(frames);
        assert(!frames.empty);
    }
    body
    {
        _frames = frames;
    }

    /**
     * Gets the stack frames of this stack trace.
     *
     * The most recent call is the last element of the list.
     *
     * Returns:
     *  The stack frames of this stack trace.
     */
    @property public ReadOnlyIndexable!StackFrame frames()
    out (result)
    {
        assert(result);
        assert(!(cast()result).empty);
    }
    body
    {
        return _frames;
    }
}

/**
 * Represents a stack frame in a managed stack trace.
 */
public final class StackFrame
{
    private Instruction _instruction;

    invariant()
    {
        assert(_instruction);
    }

    /**
     * Constructs a new $(D StackFrame) instance.
     *
     * Params:
     *  instruction = The instruction that was executing
     *                in this stack frame.
     */
    public this(Instruction instruction) nothrow
    in
    {
        assert(instruction);
    }
    body
    {
        _instruction = instruction;
    }

    /**
     * Gets the instruction that was executing at this frame.
     *
     * Returns:
     *  The instruction that was executing at this frame.
     */
    @property public Instruction instruction() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _instruction;
    }
}
