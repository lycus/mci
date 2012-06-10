module mci.verifier.manager;

import mci.core.container,
       mci.core.code.functions,
       mci.verifier.passes.control,
       mci.verifier.passes.misc,
       mci.verifier.passes.ordering,
       mci.verifier.passes.typing,
       mci.verifier.base;

/**
 * Manages and executes verification passes.
 */
public final class VerificationManager
{
    private NoNullList!CodeVerifier _verifiers;

    invariant()
    {
        assert(_verifiers);
    }

    /**
     * Constructs a new $(D VerificationManager) instance.
     */
    public this()
    {
        _verifiers = new typeof(_verifiers)();

        addRange(_verifiers,
                 toIterable!CodeVerifier(new SSAFormVerifier(),
                                         new EntryVerifier(),
                                         new UnwindVerifier(),
                                         new RegisterVerifier(),
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
                                         new TailCallReturnVerifier(),
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
                                         new ArrayArithmeticVerifier(),
                                         new ArrayBitwiseVerifier(),
                                         new ArrayBitShiftVerifier(),
                                         new ArrayComparisonVerifier(),
                                         new ArrayConversionVerifier(),
                                         new FieldTypeVerifier(),
                                         new UserFieldVerifier(),
                                         new FieldStorageVerifier(),
                                         new TrampolineVerifier()));
    }

    /**
     * Runs all verification passes on a function.
     *
     * Params:
     *  function_ = The function to verify.
     *
     * Throws:
     *  $(D VerifierException) if verification fails.
     */
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
