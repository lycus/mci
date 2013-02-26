module mci.core.log;

import std.algorithm,
       std.datetime,
       std.process,
       std.stdio,
       mci.core.sync,
       mci.core.utilities;

private __gshared Mutex mutex;

shared static this()
{
    mutex = new typeof(mutex)();
}

private bool isLogLevel(string check)() nothrow
in
{
    assert(check);
}
body
{
    auto level = Environment.get("MCI_LOG_LEVEL");

    if (!level)
        return false;

    static if (check == "info")
        auto levels = ["info", "warning", "error", "debug"];
    else static if (check == "warning")
        auto levels = ["warning", "error", "debug"];
    else static if (check == "error")
        auto levels = ["error", "debug"];
    else static if (check == "debug")
        auto levels = ["debug"];
    else
        static assert(false);

    return canFind(levels, level);
}

private void output(T ...)(string source, T args)
{
    mutex.lock();

    scope (exit)
        mutex.unlock();

    stderr.writefln("[%s] [%s] %s", Clock.currTime(), source, format(args));
}

private void logInfo(T ...)(string source, T args)
{
    if (isLogLevel!"info"())
        output(source, args);
}

private void logWarning(T ...)(string source, T args)
{
    if (isLogLevel!"warning"())
        output(source, args);
}

private void logError(T ...)(string source, T args)
{
    if (isLogLevel!"error"())
        output(source, args);
}

private void logDebug(T ...)(string source, T args)
{
    debug
        if (isLogLevel!"debug"())
            output(source, args);
}

public struct LogProxy
{
    private string _source;

    pure nothrow invariant()
    {
        assert(_source);
    }

    @disable this();

    public this(string source) pure nothrow
    in
    {
        assert(source);
    }
    body
    {
        _source = source;
    }

    @property public string source() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _source;
    }

    public void logInfo(T ...)(T args)
    {
        .logInfo(_source, args);
    }

    public void logWarning(T ...)(T args)
    {
        .logWarning(_source, args);
    }

    public void logError(T ...)(T args)
    {
        .logError(_source, args);
    }

    public void logDebug(T ...)(T args)
    {
        .logDebug(_source, args);
    }
}

public mixin template Logger(string name = "log")
{
    mixin("import std.traits;" ~
          "" ~
          "private __gshared LogProxy " ~ name ~ " = typeof(" ~ name ~ ")(moduleName!_module__level__log__symbol_);;" ~
          "private __gshared ubyte _module__level__log__symbol_;");
}
