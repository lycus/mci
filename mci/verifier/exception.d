module mci.verifier.exception;

import mci.core.exception,
       mci.core.code.instructions;

public class VerifierException : CompilerException
{
    private Instruction _instruction;

    public this(Instruction instruction, string msg, string file = __FILE__, size_t line = __LINE__)
    in
    {
        assert(msg);
        assert(file);
        assert(line);
    }
    body
    {
        super(msg, file, line);

        _instruction = instruction;
    }

    public this(Instruction instruction, string msg, Throwable next, string file = __FILE__, size_t line = __LINE__)
    in
    {
        assert(msg);
        assert(next);
        assert(file);
        assert(line);
    }
    body
    {
        super(msg, next, file, line);

        _instruction = instruction;
    }

    @property public final Instruction instruction()
    {
        return _instruction;
    }
}
