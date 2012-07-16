module mci.verifier.base;

import mci.core.utilities,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.verifier.exception;

/**
 * Represents an IR verification pass.
 */
public abstract class CodeVerifier
{
    /**
     * Verifies a specific subset of the IR in the given function.
     *
     * Params:
     *  function_ = The function to verify IR in.
     *
     * Throws:
     *  $(D VerifierException) if verification fails.
     */
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
