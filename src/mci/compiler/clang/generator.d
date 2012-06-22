module mci.compiler.clang.generator;

import mci.compiler.clang.alu,
       mci.compiler.clang.arrays,
       mci.compiler.clang.control,
       mci.compiler.clang.memory,
       mci.compiler.clang.misc,
       mci.compiler.clang.structures,
       mci.core.io,
       mci.core.code.functions,
       mci.vm.execution;

/**
 * Generates Clang-compatible C99 code from IAL. The emitted code
 * is only valid for the given $(D ExecutionEngine) and the current
 * process.
 */
public final class ClangCGenerator
{
    private ExecutionEngine _engine;
    private Stream _stream;
    private TextWriter _writer;
    private bool _done;

    invariant()
    {
        assert(_engine);
        assert(_stream);
        assert((cast()_stream).canWrite);
        assert(!(cast()_stream).isClosed);
        assert(_writer);
    }

    /**
     * Constructs a new $(D ClangCGenerator) instance.
     *
     * Params:
     *  stream = The stream to write to.
     */
    public this(ExecutionEngine engine, Stream stream)
    in
    {
        assert(engine);
        assert(stream);
        assert((cast()stream).canWrite);
        assert(!(cast()stream).isClosed);
    }
    body
    {
        _engine = engine;
        _stream = stream;
        _writer = new typeof(_writer)(stream);
    }

    /**
     * Generates the C99 code for the given function.
     *
     * This actually generates code for all functions that
     * the given function could possibly end up calling. That
     * is, it could easily generate code for several modules.
     *
     * Params:
     *  function_ = The function to generate C99 code for.
     */
    public void write(Function function_)
    in
    {
        assert(function_);
        assert(!_done);
    }
    body
    {
        _done = true;

        assert(false);
    }
}
