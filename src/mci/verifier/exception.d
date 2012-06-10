module mci.verifier.exception;

import mci.core.exception,
       mci.core.code.instructions;

/**
 * The exception thrown by the verification pipeline
 * if some kind of verification failed.
 */
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

    /**
     * Gets the instruction that caused the verification
     * failure, if any.
     *
     * Returns:
     *  The instruction causing the verification failure,
     *  if any.
     */
    @property public final Instruction instruction() pure nothrow
    {
        return _instruction;
    }
}
