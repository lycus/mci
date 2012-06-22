module mci.cli.tools.jit;

import core.memory,
       std.getopt,
       std.path,
       mci.cli.main,
       mci.cli.tool,
       mci.core.config,
       mci.core.container,
       mci.core.exception,
       mci.core.io,
       mci.core.code.modules,
       mci.jit.engine,
       mci.vm.intrinsics.declarations,
       mci.vm.io.exception,
       mci.vm.io.reader,
       mci.vm.exception,
       mci.vm.execution,
       mci.vm.memory.base,
       mci.vm.memory.boehm,
       mci.vm.memory.dgc,
       mci.vm.memory.libc;

public final class JITTool : Tool
{
    @property public string name() pure nothrow
    {
        return "jit";
    }

    @property public string description() pure nothrow
    {
        return "Run an assembled module with the just-in-time compiler.";
    }

    @property public string[] options() pure nothrow
    {
        return null;
    }

    public int run(string[] args)
    {
        JITBackEnd backEnd;
        GarbageCollectorType gcType;

        try
        {
            getopt(args,
                   config.caseSensitive,
                   config.bundling,
                   "backend|b", &backEnd,
                   "collector|c", &gcType);
            args = args[1 .. $];
        }
        catch (Exception ex)
        {
            logf("Error: Could not parse command line: %s", ex.msg);
            return 2;
        }

        if (args.length != 1)
        {
            log("Error: Exactly one input module must be given.");
            return 2;
        }

        auto file = args[0];

        if (file[0] == '.' && file.length <= moduleFileExtension.length + 1)
        {
            logf("Error: Input module '%s' has no name part.", file);
            return 2;
        }

        if (extension(file) != moduleFileExtension)
        {
            logf("Error: Input module '%s' does not end in '%s'.", file, moduleFileExtension);
            return 2;
        }

        FileStream stream;

        try
        {
            auto manager = new ModuleManager();
            manager.attach(intrinsicModule);

            auto reader = new ModuleReader(manager);
            auto mod = reader.load(file);
            auto main = mod.entryPoint;

            if (!main)
            {
                logf("Error: Module %s has no entry point.");
                return 1;
            }

            GarbageCollector gc;

            final switch (gcType)
            {
                case GarbageCollectorType.libc:
                    gc = new LibCGarbageCollector();
                    break;
                case GarbageCollectorType.dgc:
                    gc = new DGarbageCollector();
                    break;
                static if (isPOSIX)
                {
                    case GarbageCollectorType.boehm:
                        gc = new BoehmGarbageCollector();
                        break;
                }
            }

            auto engine = new JITEngine(backEnd, gc);

            try
                return *cast(int*)engine.execute(main, new NoNullList!RuntimeValue()).data;
            catch (ExecutionException ex)
            {
                // TODO: Print a stack trace.

                auto rtv = ex.exception;

                clear(ex);
                GC.free(cast(void*)ex);

                clear(rtv);
                GC.free(cast(void*)rtv);
            }
            finally
            {
                engine.terminate();
                gc.terminate();
            }
        }
        catch (IOException ex)
        {
            logf("Error: Could not access '%s': %s", file, ex.msg);
            return 1;
        }
        catch (ReaderException ex)
        {
            logf("Error: Could not load '%s': %s", file, ex.msg);
            return 1;
        }
        finally
        {
            if (stream)
                stream.close();
        }

        return 0;
    }
}
