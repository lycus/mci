module mci.vm.exception;

import mci.core.exception,
       mci.core.code.instructions,
       mci.vm.execution;

public class ExecutionException : CompilerException
{
    private Instruction _instruction;
    private RuntimeValue _exception;

    invariant()
    {
        assert(_instruction);
        assert(_exception);
    }

    public this(Instruction instruction, RuntimeValue exception, string msg, string file = __FILE__, size_t line = __LINE__)
    in
    {
        assert(instruction);
        assert(exception);
        assert(msg);
        assert(file);
        assert(line);
    }
    body
    {
        super(msg, file, line);

        _instruction = instruction;
        _exception = exception;
    }

    public this(Instruction instruction, RuntimeValue exception, string msg, Throwable next, string file = __FILE__, size_t line = __LINE__)
    in
    {
        assert(instruction);
        assert(exception);
        assert(msg);
        assert(next);
        assert(file);
        assert(line);
    }
    body
    {
        super(msg, next, file, line);

        _instruction = instruction;
        _exception = exception;
    }

    @property public Instruction instruction()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _instruction;
    }

    @property public RuntimeValue exception()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _exception;
    }
}
