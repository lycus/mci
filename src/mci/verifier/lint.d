module mci.verifier.lint;

import std.string,
       mci.core.container,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.opcodes;

public final class LintMessage
{
    private Instruction _instruction;
    private string _message;

    invariant()
    {
        assert(_instruction);
        assert(_message);
    }

    public this(Instruction instruction, string message)
    in
    {
        assert(instruction);
        assert(message);
    }
    body
    {
        _instruction = instruction;
        _message = message;
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

public alias void delegate(Function, NoNullList!LintMessage) LintPass;

public final class Linter
{
    private NoNullList!LintPass _passes;

    invariant()
    {
        assert(_passes);
    }

    public this()
    {
        _passes = new typeof(_passes)();
    }

    @property public NoNullList!LintPass passes() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _passes;
    }

    public ReadOnlyIndexable!LintMessage lint(Function function_)
    in
    {
        assert(function_);
        assert(function_.attributes & FunctionAttributes.ssa);
    }
    body
    {
        auto messages = new NoNullList!LintMessage();

        foreach (pass; _passes)
            pass(function_, messages);

        return messages;
    }
}

public __gshared ReadOnlyCollection!LintPass standardPasses;

shared static this()
{
    auto passes = new NoNullList!LintPass();

    passes.add((msgs, insn) => lintReturningStackAllocatedMemory(msgs, insn));

    standardPasses = passes;
}

private void message(T ...)(NoNullList!LintMessage messages, Instruction instruction, string message, T args)
in
{
    assert(messages);
    assert(message);
}
body
{
    messages.add(new LintMessage(instruction, format(message, args)));
}

private void lintReturningStackAllocatedMemory(Function function_, NoNullList!LintMessage messages)
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

                if (def.opCode is opMemSAlloc || def.opCode is opMemSNew)
                    message(messages, insn, "Returning stack-allocated memory.");
            }
        }
    }
}
