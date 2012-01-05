module mci.verifier.base;

import std.string,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.verifier.exception;

public abstract class CodeVerifier
{
    public abstract void verify(Function function_);

    protected static void error(T ...)(Instruction instruction, string message, T args)
    in
    {
        assert(message);
    }
    body
    {
        throw new VerifierException(instruction, format(message, args));
    }
}
