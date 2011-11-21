module mci.cli.tools.assembler;

import std.algorithm,
       std.conv,
       std.exception,
       std.getopt,
       std.utf,
       mci.core.container,
       mci.core.io,
       mci.assembler.exception,
       mci.assembler.generation.driver,
       mci.assembler.generation.exception,
       mci.vm.io.writer,
       mci.assembler.parsing.exception,
       mci.assembler.parsing.lexer,
       mci.assembler.parsing.parser,
       mci.cli.main,
       mci.cli.tool,
       mci.cli.tools.interpreter;

public enum string inputFileExtension = ".ial";
public enum string outputFileExtension = ".mci";

public final class AssemblerTool : Tool
{
    @property public string description()
    {
        return "Assemble IAL modules into a program.";
    }

    @property public string[] options()
    {
        return ["\t--output=<file>\t\t-o <file>\tSpecify program output file.",
                "\t--verify\t\t-v\t\tRun IAL verifier on input modules.",
                "\t--optimize\t\t-p\t\tPass the program through the optimization pipeline.",
                "\t--interpret\t\t-t\t\tRun the program with the IAL interpreter (no output will be generated).",
                "\t--collector=<type>\t-c <type>\tSpecify which garbage collector to use if running the program."];
    }

    public bool run(string[] args)
    {
        string output = "out.mci";
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

        if (!endsWith(output, outputFileExtension))
        {
            logf("Output file '%s' does not end in '%s'.", output, outputFileExtension);
            return false;
        }

        if (args.length == 0)
        {
            log("Error: No modules given.");
            return false;
        }

        auto units = new NoNullDictionary!(string, CompilationUnit)();

        foreach (file; args)
        {
            if (!endsWith(file, inputFileExtension))
            {
                logf("Error: File '%s' does not end in '%s'.", file, inputFileExtension);
                return false;
            }

            if (file.length <= inputFileExtension.length)
            {
                logf("Error: File '%s' is missing a module name.", file);
                return false;
            }

            auto modName = file[0 .. $ - inputFileExtension.length];

            foreach (mod; units.keys)
            {
                if (modName == mod)
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

                units.add(modName, unit);
            }
            catch (ErrnoException ex)
            {
                logf("Error: Could not read '%s': %s", file, ex.msg);
                return false;
            }
            catch (UtfException ex)
            {
                log("Error: UTF-8 decoding failed; file '%s' is probably not plain text.", file);
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
        FileStream file;

        try
        {
            driver = new GeneratorDriver(units);
            auto program = driver.run();
            file = new FileStream(output, FileAccess.write, FileMode.truncate);
            auto writer = new ProgramWriter(file);

            writer.write(program);
        }
        catch (ErrnoException ex)
        {
            logf("Error: Could not write '%s': %s", output, ex.msg);
            return false;
        }
        catch (GenerationException ex)
        {
            logf("Error: Generation failed in '%s' (line %s%s): %s", driver.currentModule ~ inputFileExtension,
                 ex.location.line, ex.location.column == 0 ? "" : ", column " ~ to!string(ex.location.column), ex.msg);
            return false;
        }
        finally
        {
            if (file)
                file.close();
        }

        return true;
    }
}
