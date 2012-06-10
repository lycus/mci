module mci.cli.tools.graph;

import std.exception,
       std.getopt,
       std.path,
       mci.cli.main,
       mci.cli.tool,
       mci.core.container,
       mci.core.io,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.graph,
       mci.core.code.modules,
       mci.verifier.exception,
       mci.verifier.manager,
       mci.vm.intrinsics.declarations,
       mci.vm.io.exception,
       mci.vm.io.reader;

public enum string graphFileExtension = ".dot";

public final class GraphTool : Tool
{
    @property public string name() pure nothrow
    {
        return "graph";
    }

    @property public string description() pure nothrow
    {
        return "Outputs a Graphviz-compatible DOT specification of a function.";
    }

    @property public string[] options() pure nothrow
    {
        return ["\t--output=<file>\t\t-o <file>\tSpecify module output file."];
    }

    public ubyte run(string[] args)
    {
        string output = "out.dot";

        try
        {
            getopt(args,
                   config.caseSensitive,
                   config.bundling,
                   "output|o", &output);
            args = args[1 .. $];
        }
        catch (Exception ex)
        {
            logf("Error: Could not parse command line: %s", ex.msg);
            return 2;
        }

        if (args.length != 2)
        {
            log("Error: Exactly one input module and one function name must be given.");
            return 2;
        }

        if (output[0] == '.' && output.length <= graphFileExtension.length + 1)
        {
            logf("Error: Output file '%s' has no name part.", output);
            return 2;
        }

        if (extension(output) != graphFileExtension)
        {
            logf("Error: Output file '%s' does not end in '%s'.", output, graphFileExtension);
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
        Function currentFunc;

        try
        {
            auto manager = new ModuleManager();
            manager.attach(intrinsicModule);

            auto reader = new ModuleReader(manager);
            auto mod = reader.load(file);

            auto verifier = new VerificationManager();

            foreach (func; mod.functions)
            {
                currentFunc = func.y;
                verifier.verify(func.y);
            }

            stream = new FileStream(output, FileMode.truncate);
            auto graph = new GraphWriter(stream);

            auto funcName = args[1];

            if (auto func = mod.functions.get(funcName))
                graph.write(*func);
            else
            {
                logf("Error: Function '%s' does not exist.", funcName);
                return 2;
            }
        }
        catch (ErrnoException ex)
        {
            logf("Error: Could not access '%s': %s", file, ex.msg);
            return 1;
        }
        catch (ReaderException ex)
        {
            logf("Error: Could not load '%s': %s", file, ex.msg);
            return 1;
        }
        catch (VerifierException ex)
        {
            logf("Error: Verification failed in function %s:", currentFunc);
            log(ex.msg);

            if (ex.instruction)
            {
                log();
                logf("The invalid instruction was (index %s in block %s):", findIndex(ex.instruction.block.stream, ex.instruction),
                     ex.instruction.block);
                log(ex.instruction);
            }

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
