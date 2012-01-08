module mci.verifier.manager;

import mci.core.container,
       mci.core.code.functions,
       mci.verifier.passes.control,
       mci.verifier.passes.ordering,
       mci.verifier.passes.typing,
       mci.verifier.base;

public final class VerificationManager
{
    private NoNullList!CodeVerifier _verifiers;

    invariant()
    {
        assert(_verifiers);

        addRange(_verifiers,
                 toIterable!CodeVerifier(new EntryVerifier(),
                                         new TerminatorVerifier(),
                                         new JumpVerifier(),
                                         new ReturnVerifier(),
                                         new ReturnTypeVerifier(),
                                         new FFIVerifier(),
                                         new RawVerifier(),
                                         new ConstantLoadVerifier(),
                                         new ArithmeticVerifier(),
                                         new BitwiseVerifier(),
                                         new ShiftVerifier(),
                                         new ComparisonVerifier(),
                                         new MemoryVerifier(),
                                         new MemoryAliasVerifier()));
    }

    public this()
    {
        _verifiers = new typeof(_verifiers)();
    }

    public void verify(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
        foreach (verifier; _verifiers)
            verifier.verify(function_);
    }
}
