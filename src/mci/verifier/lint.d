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
    if (!function_.returnType)
        return;

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
