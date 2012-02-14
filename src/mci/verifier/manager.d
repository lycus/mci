module mci.verifier.manager;

import mci.core.container,
       mci.core.code.functions,
       mci.verifier.passes.control,
       mci.verifier.passes.misc,
       mci.verifier.passes.ordering,
       mci.verifier.passes.typing,
       mci.verifier.base;

public final class VerificationManager
{
    private NoNullList!CodeVerifier _verifiers;

    invariant()
    {
        assert(_verifiers);
    }

    public this()
    {
        _verifiers = new typeof(_verifiers)();

        addRange(_verifiers,
                 toIterable!CodeVerifier(new SSAFormVerifier(),
                                         new EntryVerifier(),
                                         new UnwindVerifier(),
                                         new TerminatorVerifier(),
                                         new FFIVerifier(),
                                         new RawVerifier(),
                                         new JumpVerifier(),
                                         new JumpTypeVerifier(),
                                         new ReturnVerifier(),
                                         new ReturnTypeVerifier(),
                                         new PhiOrderVerifier(),
                                         new PhiRegisterCountVerifier(),
                                         new PhiRegisterVerifier(),
                                         new PhiTypeVerifier(),
                                         new PhiPredecessorVerifier(),
                                         new ExceptionContextVerifier(),
                                         new ExceptionTypeVerifier(),
                                         new CallSiteOrderVerifier(),
                                         new CallSiteCountVerifier(),
                                         new CallSiteTypeVerifier(),
                                         new FunctionArgumentOrderVerifier(),
                                         new FunctionArgumentCountVerifier(),
                                         new FunctionArgumentTypeVerifier(),
                                         new ConstantLoadVerifier(),
                                         new ArithmeticVerifier(),
                                         new BitwiseVerifier(),
                                         new BitShiftVerifier(),
                                         new ComparisonVerifier(),
                                         new ConversionVerifier(),
                                         new MemoryVerifier(),
                                         new MemoryPinVerifier(),
                                         new MemoryAliasVerifier(),
                                         new ArrayVerifier(),
                                         new FieldTypeVerifier(),
                                         new FieldStorageVerifier()));
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
