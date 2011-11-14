module mci.cli.tools.assembler;

import std.algorithm,
       std.conv,
       std.file,
       std.stdio,
       std.utf,
       mci.core.container,
       mci.core.io,
       mci.assembler.exception,
       mci.assembler.generation.driver,
       mci.assembler.generation.exception,
       mci.assembler.parsing.exception,
       mci.assembler.parsing.lexer,
       mci.assembler.parsing.parser,
       mci.cli.tool;

public enum string fileExtension = ".ial";

public final class AssemblerTool : Tool
{
    public bool run(NoNullList!string args)
    {
        if (args.count == 0)
        {
            writeln("Error: No modules given.");
            return false;
        }

        auto units = new NoNullDictionary!(string, CompilationUnit)();

        foreach (file; args)
        {
            if (!endsWith(file, fileExtension))
            {
                writefln("Error: File %s does not end in \".ial\".", file);
                return false;
            }

            if (file.length <= fileExtension.length)
            {
                writefln("Error: File %s is missing a module name.", file);
                return false;
            }

            auto modName = file[0 .. $ - fileExtension.length];

            foreach (mod; units.keys)
            {
                if (modName == mod)
                {
                    writefln("Error: File %s specified multiple times.", file);
                    return false;
                }
            }

            try
            {
                auto source = new Source(cast(string)read(file));
                auto lexer = new Lexer(source);
                auto parser = new Parser(lexer.lex());
                auto unit = parser.parse();

                units.add(modName, unit);
            }
            catch (FileException ex)
            {
                writefln("Error: Could not open file: %s", ex.msg);
                return false;
            }
            catch (UtfException ex)
            {
                writeln("Error: UTF-8 decoding failed; file is probably not plain text.");
                return false;
            }
            catch (LexerException ex)
            {
                writefln("Lexer error in %s (%s%s): %s", file, ex.location.line,
                         ex.location.column == 0 ? "" : ", " ~ to!string(ex.location.column), ex.msg);
                return false;
            }
            catch (ParserException ex)
            {
                writefln("Parser error in %s (%s%s): %s", file, ex.location.line,
                         ex.location.column == 0 ? "" : ", " ~ to!string(ex.location.column), ex.msg);
                return false;
            }
            catch (AssemblerException ex)
            {
                writefln("Assembler error in %s: %s", file, ex.msg);
                return false;
            }
        }

        try
        {
            auto driver = new GeneratorDriver(units);
            auto program = driver.run();
        }
        catch (GenerationException ex)
        {
            writefln("%s", ex.msg);
        }

        return true;
    }
}
