module mci.vm.trace;

import mci.core.container,
       mci.core.code.instructions;

public final class StackTrace
{
    private NoNullList!StackFrame _frames;

    invariant()
    {
        assert(_frames);
        assert(!(cast()_frames).empty);
    }

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

public final class StackFrame
{
    private Instruction _instruction;

    invariant()
    {
        assert(_instruction);
    }

    public this(Instruction instruction)
    in
    {
        assert(instruction);
    }
    body
    {
        _instruction = instruction;
    }

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
