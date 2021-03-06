module mci.verifier.lint;

import mci.core.container,
       mci.core.utilities,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.opcodes,
       mci.core.typing.types;

/**
 * Represents a message emitted by the linter.
 */
public final class LintMessage
{
    private Instruction _instruction;
    private string _message;

    pure nothrow invariant()
    {
        assert(_message);
    }

    private this(Instruction instruction, string message) pure nothrow
    in
    {
        assert(message);
    }
    body
    {
        _instruction = instruction;
        _message = message;
    }

    /**
     * Gets the instruction that triggered the message, if any.
     *
     * Returns:
     *  The instruction that triggered the message, if any.
     */
    @property public Instruction instruction() pure nothrow
    {
        return _instruction;
    }

    /**
     * Gets the actual message as a string.
     *
     * Returns:
     *  The actual message as a string.
     */
    @property public string message() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _message;
    }
}

public alias void delegate(Function, NoNullList!LintMessage) LintPass; /// Represents a lint pass.

/**
 * Manages and executes linting passes on functions.
 */
public final class Linter
{
    private NoNullList!LintPass _passes;

    pure nothrow invariant()
    {
        assert(_passes);
    }

    /**
     * Constructs a new $(D Linter) instance.
     */
    public this()
    {
        _passes = new typeof(_passes)();
    }

    /**
     * Gets the list of lint passes in this instance.
     *
     * Returns:
     *  The list of lint passes in this instance.
     */
    @property public NoNullList!LintPass passes() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _passes;
    }

    /**
     * Runs all registered lint passes on the given function.
     *
     * Params:
     *  function_ = The function to lint.
     *
     * Returns:
     *  A collection of messages emitted by the lint passes executed
     *  on $(D function_). Can be empty if no problems were found.
     */
    public ReadOnlyIndexable!LintMessage lint(Function function_)
    in
    {
        assert(function_);
        assert(function_.attributes & FunctionAttributes.ssa);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto messages = new NoNullList!LintMessage();

        foreach (pass; _passes)
            pass(function_, messages);

        return messages;
    }
}

public __gshared ReadOnlyCollection!LintPass standardPasses; /// Lint passes included in this module.

shared static this()
{
    auto passes = new NoNullList!LintPass();

    passes.add((fn, msgs) => lintMeaninglessInstructionAttribute(fn, msgs));
    passes.add((fn, msgs) => lintMeaninglessParameterAttribute(fn, msgs));
    passes.add((fn, msgs) => lintLeakingStackAllocatedMemory(fn, msgs));
    passes.add((fn, msgs) => lintReturningFromNoReturnFunction(fn, msgs));
    passes.add((fn, msgs) => lintThrowingInNoThrowFunction(fn, msgs));
    passes.add((fn, msgs) => lintDeletingImmutableMemory(fn, msgs));
    passes.add((fn, msgs) => lintLeakingNoEscapeParameter(fn, msgs));

    standardPasses = passes;
}

public void message(T ...)(NoNullList!LintMessage messages, Instruction instruction, string message, T args)
in
{
    assert(messages);
    assert(message);
}
body
{
    messages.add(new LintMessage(instruction, format(message, args)));
}

private void lintMeaninglessInstructionAttribute(Function function_, NoNullList!LintMessage messages)
in
{
    assert(function_);
    assert(function_.attributes & FunctionAttributes.ssa);
    assert(messages);
}
body
{
    foreach (bb; function_.blocks)
        foreach (insn; bb.y.stream)
            if (insn.attributes & InstructionAttributes.volatile_ && !hasMeaning(InstructionAttributes.volatile_, insn.opCode))
                message(messages, insn, "The volatile attribute has no effect on this instruction.");
}

private void lintMeaninglessParameterAttribute(Function function_, NoNullList!LintMessage messages)
in
{
    assert(function_);
    assert(function_.attributes & FunctionAttributes.ssa);
    assert(messages);
}
body
{
    foreach (param; function_.parameters)
        if (param.attributes & ParameterAttributes.noEscape && !hasAliasing(param.type))
            message(messages, null, "The noescape attribute has no meaning for type %s as it has no aliasing.", param.type);
}

private void lintLeakingStackAllocatedMemory(Function function_, NoNullList!LintMessage messages)
in
{
    assert(function_);
    assert(function_.attributes & FunctionAttributes.ssa);
    assert(messages);
}
body
{
    foreach (bb; function_.blocks)
    {
        foreach (insn; bb.y.stream)
        {
            if (insn.opCode is opReturn)
            {
                auto def = first(insn.sourceRegister1.definitions);

                if (def.opCode is opMemSAlloc || def.opCode is opMemSNew || def.opCode is opMemAddr)
                    message(messages, insn, "Returning stack-allocated memory.");
            }
            else if (insn.opCode is opMemSet)
            {
                auto ptrDef = first(insn.sourceRegister1.definitions);
                auto valDef = first(insn.sourceRegister2.definitions);

                if ((ptrDef.opCode is opFieldGlobalAddr || ptrDef.opCode is opFieldThreadAddr) &&
                    (valDef.opCode is opMemSAlloc || valDef.opCode is opMemSNew || valDef.opCode is opMemAddr))
                    message(messages, insn, "Leaking stack-allocated memory.");
            }
        }
    }
}

private void lintReturningFromNoReturnFunction(Function function_, NoNullList!LintMessage messages)
in
{
    assert(function_);
    assert(function_.attributes & FunctionAttributes.ssa);
    assert(messages);
}
body
{
    if (!(function_.attributes & FunctionAttributes.noReturn))
        return;

    foreach (bb; function_.blocks)
    {
        foreach (insn; bb.y.stream)
        {
            if (insn.opCode is opLeave || insn.opCode is opReturn)
                message(messages, insn, "Returning from a noreturn function.");
            else if (isDirectCallSite(insn.opCode) && !(insn.operand.peek!Function().attributes & FunctionAttributes.noReturn))
                message(messages, insn, "Calling non-noreturn function in noreturn function.");
        }
    }
}

private void lintThrowingInNoThrowFunction(Function function_, NoNullList!LintMessage messages)
in
{
    assert(function_);
    assert(function_.attributes & FunctionAttributes.ssa);
    assert(messages);
}
body
{
    if (!(function_.attributes & FunctionAttributes.noThrow))
        return;

    foreach (bb; function_.blocks)
    {
        foreach (insn; bb.y.stream)
        {
            if (insn.opCode is opEHThrow || insn.opCode is opEHRethrow)
                message(messages, insn, "Throwing in a nothrow function.");
            else if (isDirectCallSite(insn.opCode) && !(insn.operand.peek!Function().attributes & FunctionAttributes.noThrow))
                message(messages, insn, "Calling non-nothrow function in nothrow function.");
        }
    }
}

private void lintDeletingImmutableMemory(Function function_, NoNullList!LintMessage messages)
in
{
    assert(function_);
    assert(function_.attributes & FunctionAttributes.ssa);
    assert(messages);
}
body
{
    foreach (bb; function_.blocks)
    {
        foreach (insn; bb.y.stream)
        {
            if (insn.opCode is opMemFree)
            {
                auto def = first(insn.sourceRegister1.definitions);

                if (def.opCode is opLoadData || def.opCode is opFieldGlobalAddr || def.opCode is opFieldThreadAddr ||
                    def.opCode is opMemSAlloc || def.opCode is opMemSNew || def.opCode is opMemAddr ||
                    (def.opCode is opFieldAddr && cast(StructureType)def.sourceRegister1.type))
                    message(messages, insn, "Deleting immutable memory (data block, stack, or global/thread field memory).");
            }
        }
    }
}

private void lintLeakingNoEscapeParameter(Function function_, NoNullList!LintMessage messages)
in
{
    assert(function_);
    assert(function_.attributes & FunctionAttributes.ssa);
    assert(messages);
}
body
{
    if (function_.parameters.empty)
        return;

    foreach (bb; function_.blocks)
    {
        foreach (insn; bb.y.stream)
        {
            if (insn.opCode is opReturn)
            {
                auto def = first(insn.sourceRegister1.definitions);

                if (def.opCode is opArgPop && function_.parameters[findIndex(def.block.stream, def)].attributes & ParameterAttributes.noEscape)
                    message(messages, insn, "Returning a noescape parameter.");
            }
            else if (insn.opCode is opMemSet)
            {
                auto ptrDef = first(insn.sourceRegister1.definitions);
                auto valDef = first(insn.sourceRegister2.definitions);

                if ((ptrDef.opCode is opFieldGlobalAddr || ptrDef.opCode is opFieldThreadAddr) &&
                    (valDef.opCode is opArgPop && function_.parameters[findIndex(valDef.block.stream, valDef)].attributes & ParameterAttributes.noEscape))
                    message(messages, insn, "Leaking a noescape parameter.");
            }
            else if (insn.opCode is opEHThrow)
            {
                auto def = first(insn.sourceRegister1.definitions);

                if (def.opCode is opArgPop && function_.parameters[findIndex(def.block.stream, def)].attributes & ParameterAttributes.noEscape)
                    message(messages, insn, "Throwing a noescape parameter.");
            }
        }
    }
}
