module mci.vm.exception;

import mci.core.exception,
       mci.core.code.instructions,
       mci.vm.execution,
       mci.vm.trace;

public class ExecutionException : CompilerException
{
    private StackTrace _trace;
    private RuntimeValue _exception;

    invariant()
    {
        assert(_trace);
        assert(_exception);
    }

    public this(StackTrace trace, RuntimeValue exception, string msg, string file = __FILE__, size_t line = __LINE__)
    in
    {
        assert(trace);
        assert(exception);
        assert(msg);
        assert(file);
        assert(line);
    }
    body
    {
        super(msg, file, line);

        _trace = trace;
        _exception = exception;
    }

    public this(StackTrace trace, RuntimeValue exception, string msg, Throwable next, string file = __FILE__, size_t line = __LINE__)
    in
    {
        assert(trace);
        assert(exception);
        assert(msg);
        assert(next);
        assert(file);
        assert(line);
    }
    body
    {
        super(msg, next, file, line);

        _trace = trace;
        _exception = exception;
    }

    @property public StackTrace trace()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _trace;
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
