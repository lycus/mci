module mci.cli.tools.assembler;

import std.algorithm,
       std.conv,
       std.file,
       std.getopt,
       std.stdio,
       std.utf,
       mci.core.container,
       mci.core.io,
       mci.assembler.exception,
       mci.assembler.generation.driver,
       mci.assembler.generation.exception,
       mci.assembler.io.writer,
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
        }
        catch (Exception ex)
        {
            logf("Error parsing command line: %s", ex.msg);
            return false;
        }

        if (!endsWith(output, outputFileExtension))
        {
            logf("Output file %s does not end in \"%s\".", outputFileExtension, output);
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
                logf("Error: File %s does not end in \"%s\".", inputFileExtension, file);
                return false;
            }

            if (file.length <= inputFileExtension.length)
            {
                logf("Error: File %s is missing a module name.", file);
                return false;
            }

            auto modName = file[0 .. $ - inputFileExtension.length];

            foreach (mod; units.keys)
            {
                if (modName == mod)
                {
                    logf("Error: File %s specified multiple times.", file);
                    return false;
                }
            }

            try
            {
                auto stream = new FileStream(file, FileAccess.read, FileMode.open);
                auto reader = new BinaryReader(stream);
                auto source = new Source(reader, stream.length);
                auto lexer = new Lexer(source);
                auto parser = new Parser(lexer.lex());
                auto unit = parser.parse();

                units.add(modName, unit);
            }
            catch (FileException ex)
            {
                logf("Error: Could not read %s: %s", file, ex.msg);
                return false;
            }
            catch (UtfException ex)
            {
                log("Error: UTF-8 decoding failed; file is probably not plain text.");
                return false;
            }
            catch (LexerException ex)
            {
                logf("Lexer error in %s (%s%s): %s", file, ex.location.line,
                     ex.location.column == 0 ? "" : ", " ~ to!string(ex.location.column), ex.msg);
                return false;
            }
            catch (ParserException ex)
            {
                logf("Parser error in %s (%s%s): %s", file, ex.location.line,
                     ex.location.column == 0 ? "" : ", " ~ to!string(ex.location.column), ex.msg);
                return false;
            }
            catch (AssemblerException ex)
            {
                logf("Assembler error in %s: %s", file, ex.msg);
                return false;
            }
        }

        auto driver = new GeneratorDriver(units);
        FileStream file;

        try
        {
            auto program = driver.run();
            file = new FileStream(output, FileAccess.write, FileMode.truncate);
            auto writer = new ProgramWriter(file);

            writer.write(program);
        }
        catch (FileException ex)
        {
            logf("Error: Could not write %s: %s", output, ex.msg);
            return false;
        }
        catch (GenerationException ex)
        {
            logf("Generator error in %s (%s%s): %s", driver.currentModule ~ inputFileExtension, ex.location.line,
                 ex.location.column == 0 ? "" : ", " ~ to!string(ex.location.column), ex.msg);
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
