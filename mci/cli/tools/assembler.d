module mci.cli.tools.assembler;

import std.algorithm,
       std.conv,
       std.exception,
       std.getopt,
       std.path,
       std.utf,
       mci.assembler.exception,
       mci.assembler.generation.driver,
       mci.assembler.generation.exception,
       mci.assembler.parsing.exception,
       mci.assembler.parsing.lexer,
       mci.assembler.parsing.parser,
       mci.core.container,
       mci.core.io,
       mci.core.code.modules,
       mci.vm.io.writer,
       mci.cli.main,
       mci.cli.tool,
       mci.cli.tools.interpreter;

public enum string inputFileExtension = ".ial";

public final class AssemblerTool : Tool
{
    @property public string description()
    {
        return "Assemble IAL files into a module.";
    }

    @property public string[] options()
    {
        return ["\t--output=<file>\t\t-o <file>\tSpecify module output file.",
                "\t--reference=<file>\t\t-r <file>\tReference a compiled module.",
                "\t--verify\t\t-v\t\tRun the IAL verifier on the resulting module.",
                "\t--optimize\t\t-p\t\tPass the module through the optimization pipeline.",
                "\t--interpret\t\t-t\t\tRun the module with the IAL interpreter (no output will be generated).",
                "\t--collector=<type>\t-c <type>\tSpecify which garbage collector to use if running the module."];
    }

    public bool run(string[] args)
    {
        string output = "out.mci";
        string[] moduleRefs;
        bool verify;
        bool optimize;
        bool interpret;
        GarbageCollectorType gcType;

        try
        {
            getopt(args,
                   config.caseSensitive,
                   config.bundling,
                   "output|o", &output,
                   "reference|r", &moduleRefs,
                   "verify|v", &verify,
                   "optimize|p", &optimize,
                   "interpret|i", &interpret,
                   "collector|c", &gcType);
            args = args[1 .. $];
        }
        catch (Exception ex)
        {
            logf("Error: Could not parse command line: %s", ex.msg);
            return false;
        }

        if (args.length == 0)
        {
            log("Error: No files given.");
            return false;
        }

        if (output.length <= moduleFileExtension.length)
        {
            logf("Error: Output file '%s' has no name part.", output);
            return false;
        }

        if (extension(output) != moduleFileExtension)
        {
            logf("Error: Output file '%s' does not end in '%s'.", output, moduleFileExtension);
            return false;
        }

        foreach (reference; moduleRefs)
        {
            if (reference.length <= moduleFileExtension.length)
            {
                logf("Error: Referenced module '%s' has no name part.", reference);
                return false;
            }

            if (extension(reference) != moduleFileExtension)
            {
                logf("Error: Referenced module '%s' does not end in '%s'.", reference, moduleFileExtension);
                return false;
            }

            if (reference == output)
            {
                logf("Error: Output file '%s' is the same as referenced module '%s'.", output, reference);
                return false;
            }
        }

        auto units = new NoNullDictionary!(string, CompilationUnit)();

        foreach (file; args)
        {
            if (file.length <= inputFileExtension.length)
            {
                logf("Error: File '%s' has no name part.", file);
                return false;
            }

            if (extension(file) != inputFileExtension)
            {
                logf("Error: File '%s' does not end in '%s'.", file, inputFileExtension);
                return false;
            }

            auto fileName = file[0 .. $ - inputFileExtension.length];

            foreach (f; units.keys)
            {
                if (fileName == f)
                {
                    logf("Error: File '%s' specified multiple times.", file);
                    return false;
                }
            }

            FileStream stream;

            try
            {
                stream = new FileStream(file);
                auto source = new Source(new BinaryReader(stream), stream.length);
                auto lexer = new Lexer(source);
                auto parser = new Parser(lexer.lex());
                auto unit = parser.parse();

                units.add(fileName, unit);
            }
            catch (ErrnoException ex)
            {
                logf("Error: Could not read '%s': %s", file, ex.msg);
                return false;
            }
            catch (UtfException ex)
            {
                logf("Error: UTF-8 decoding failed; file '%s' is probably not plain text.", file);
                return false;
            }
            catch (LexerException ex)
            {
                logf("Error: Lexing failed in '%s' (line %s%s): %s", file, ex.location.line,
                     ex.location.column == 0 ? "" : ", column " ~ to!string(ex.location.column), ex.msg);
                return false;
            }
            catch (ParserException ex)
            {
                logf("Error: Parsing failed in '%s' (line %s%s): %s", file, ex.location.line,
                     ex.location.column == 0 ? "" : ", column " ~ to!string(ex.location.column), ex.msg);
                return false;
            }
            catch (AssemblerException ex)
            {
                logf("Error: Internal error in '%s': %s", file, ex.msg);
                return false;
            }
            finally
            {
                if (stream)
                    stream.close();
            }
        }

        GeneratorDriver driver;

        try
        {
            auto manager = new ModuleManager();
            driver = new GeneratorDriver(output[0 .. $ - moduleFileExtension.length], manager, units);
            auto mod = driver.run();
            auto writer = new ModuleWriter();

            writer.save(mod, output);
        }
        catch (ErrnoException ex)
        {
            logf("Error: Could not write '%s': %s", output, ex.msg);
            return false;
        }
        catch (GenerationException ex)
        {
            logf("Error: Generation failed in '%s' (line %s%s): %s", driver.currentFile ~ inputFileExtension,
                 ex.location.line, ex.location.column == 0 ? "" : ", column " ~ to!string(ex.location.column), ex.msg);
            return false;
        }

        return true;
    }
}
