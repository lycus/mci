module mci.cli.tools.assembler;

import std.conv,
       std.exception,
       std.getopt,
       std.path,
       std.utf,
       mci.assembler.disassembly.ast,
       mci.assembler.exception,
       mci.assembler.generation.driver,
       mci.assembler.generation.exception,
       mci.assembler.parsing.exception,
       mci.assembler.parsing.lexer,
       mci.assembler.parsing.parser,
       mci.core.container,
       mci.core.io,
       mci.core.code.functions,
       mci.core.code.modules,
       mci.verifier.exception,
       mci.verifier.manager,
       mci.vm.intrinsics.declarations,
       mci.vm.io.writer,
       mci.cli.main,
       mci.cli.tool,
       mci.cli.tools.interpreter;

public enum string inputFileExtension = ".ial";

public final class AssemblerTool : Tool
{
    @property public string description() pure nothrow
    {
        return "Assemble IAL files into a module.";
    }

    @property public string[] options() pure nothrow
    {
        return ["\t--output=<file>\t\t-o <file>\tSpecify module output file.",
                "\t--dump=<file>\t\t-d <file>\tDump parsed ASTs to the given file.",
                "\t--verify\t\t-v\t\tRun the IAL verifier on the resulting module.",
                "\t--optimize\t\t-p\t\tPass the module through the optimization pipeline.",
                "\t--interpret\t\t-i\t\tRun the module with the IAL interpreter (no output will be generated).",
                "\t--collector=<type>\t-c <type>\tSpecify which garbage collector to use if running the module."];
    }

    public ubyte run(string[] args)
    {
        string output = "out.mci";
        string dump;
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
                   "dump|d", &dump,
                   "verify|v", &verify,
                   "optimize|p", &optimize,
                   "interpret|i", &interpret,
                   "collector|c", &gcType);
            args = args[1 .. $];
        }
        catch (Exception ex)
        {
            logf("Error: Could not parse command line: %s", ex.msg);
            return 2;
        }

        if (args.length == 0)
        {
            log("Error: No files given.");
            return 2;
        }

        if (output[0] == '.' && output.length <= moduleFileExtension.length + 1)
        {
            logf("Error: Output file '%s' has no name part.", output);
            return 2;
        }

        if (extension(output) != moduleFileExtension)
        {
            logf("Error: Output file '%s' does not end in '%s'.", output, moduleFileExtension);
            return 2;
        }

        string[] files;

        foreach (file; args)
        {
            if (file[0] == '.' && file.length <= moduleFileExtension.length + 1)
            {
                logf("Error: File '%s' has no name part.", file);
                return 2;
            }

            if (extension(file) != inputFileExtension)
            {
                logf("Error: File '%s' does not end in '%s'.", file, inputFileExtension);
                return 2;
            }

            foreach (f; files)
            {
                if (file == f)
                {
                    logf("Error: File '%s' specified multiple times.", file);
                    return 2;
                }
            }

            files ~= file;
        }

        auto units = new NoNullDictionary!(string, CompilationUnit)();

        foreach (file; args)
        {
            FileStream stream;

            try
            {
                stream = new FileStream(file, FileMode.read);
                auto source = new Source(new BinaryReader(stream), stream.length);
                auto lexer = new Lexer(source);
                auto parser = new Parser(lexer.lex());
                auto unit = parser.parse();

                units.add(file, unit);
            }
            catch (ErrnoException ex)
            {
                logf("Error: Could not read '%s': %s", file, ex.msg);
                return 1;
            }
            catch (UtfException ex)
            {
                logf("Error: UTF-8 decoding failed; file '%s' is probably not plain text.", file);
                return 1;
            }
            catch (LexerException ex)
            {
                logf("Error: Lexing failed in '%s' %s: %s", file, ex.location, ex.msg);
                return 1;
            }
            catch (ParserException ex)
            {
                logf("Error: Parsing failed in '%s' %s: %s", file, ex.location, ex.msg);
                return 1;
            }
            catch (AssemblerException ex)
            {
                logf("Error: Internal error in '%s': %s", file, ex.msg);
                return 1;
            }
            finally
            {
                if (stream)
                    stream.close();
            }
        }

        if (dump)
        {
            FileStream dumpStream;

            try
            {
                dumpStream = new FileStream(dump, FileMode.truncate);

                foreach (unit; units)
                {
                    auto disasm = new TreeDisassembler(unit.x, dumpStream);
                    disasm.disassemble(unit.y);
                }
            }
            catch (ErrnoException ex)
            {
                logf("Error: Could not write '%s': %s", dump, ex.msg);
                return 1;
            }
            finally
            {
                if (dumpStream)
                    dumpStream.close();
            }
        }

        GeneratorDriver driver;

        try
        {
            auto manager = new ModuleManager();
            manager.attach(intrinsicModule);

            driver = new GeneratorDriver(baseName(output[0 .. $ - moduleFileExtension.length]), manager, units);
            auto mod = driver.run();

            if (verify)
            {
                Function currentFunc;

                try
                {
                    auto verifier = new VerificationManager();

                    foreach (func; mod.functions)
                    {
                        currentFunc = func.y;
                        verifier.verify(func.y);
                    }
                }
                catch (VerifierException ex)
                {
                    logf("Error: Verification failed in function '%s':", currentFunc);
                    log(ex.msg);

                    if (ex.instruction)
                    {
                        log("The invalid instruction was:");
                        log(ex.instruction);
                    }

                    return 1;
                }
            }

            (new ModuleWriter()).save(mod, output);
        }
        catch (ErrnoException ex)
        {
            logf("Error: Could not write '%s': %s", output, ex.msg);
            return 1;
        }
        catch (GenerationException ex)
        {
            logf("Error: Generation failed in '%s' %s: %s", driver.currentFile, ex.location, ex.msg);
            return 1;
        }

        return 0;
    }
}
