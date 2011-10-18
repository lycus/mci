module mci.cli.tools.assembler;

import std.conv,
       std.file,
       std.stdio,
       std.utf,
       mci.core.io,
       mci.assembler.exception,
       mci.assembler.parsing.exception,
       mci.assembler.parsing.lexer,
       mci.assembler.parsing.parser,
       mci.cli.tool;

public final class AssemblerTool : Tool
{
    public bool run(string[] args)
    {
        foreach (file; args)
        {
            try
            {
                auto source = new Source(cast(string)read(file));
                auto lexer = new Lexer(source);
                auto parser = new Parser(lexer.lex());
                auto cu = parser.parse();
            }
            catch (FileException ex)
            {
                writefln("Could not open file: %s", ex.msg);
                return false;
            }
            catch (UtfException ex)
            {
                writeln("UTF-8 decoding failed; file is probably not plain text.");
                return false;
            }
            catch (LexerException ex)
            {
                writefln("Lexer error at %s (%s%s): %s", file, ex.location.line,
                         ex.location.column == 0 ? "" : ", " ~ to!string(ex.location.column), ex.msg);
                return false;
            }
            catch (ParserException ex)
            {
                writefln("Parser error at %s (%s%s): %s", file, ex.location.line,
                         ex.location.column == 0 ? "" : ", " ~ to!string(ex.location.column), ex.msg);
                return false;
            }
            catch (AssemblerException ex)
            {
                writefln("Assembler error at %s: %s", file, ex.msg);
                return false;
            }
        }

        return true;
    }
}
