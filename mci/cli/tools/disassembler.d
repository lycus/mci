module mci.cli.tools.disassembler;

import std.algorithm,
       std.exception,
       std.getopt,
       std.path,
       mci.assembler.disassembly.modules,
       mci.core.io,
       mci.vm.io.exception,
       mci.vm.io.reader,
       mci.cli.main,
       mci.cli.tool,
       mci.cli.tools.assembler;

public final class DisassemblerTool : Tool
{
    @property public string description()
    {
        return "Disassemble an assembled program into IAL modules.";
    }

    @property public string[] options()
    {
        return ["\t--output=<path>\t\t-o <path>\tSpecify module output directory path."];
    }

    public bool run(string[] args)
    {
        string outputDir = ".";

        try
        {
            getopt(args,
                   config.caseSensitive,
                   config.bundling,
                   "output|o", &outputDir);
            args = args[1 .. $];
        }
        catch (Exception ex)
        {
            logf("Error: Could not parse command line: %s", ex.msg);
            return false;
        }

        if (args.length == 0)
        {
            log("Error: No input programs given.");
            return false;
        }

        foreach (file; args)
        {
            if (!endsWith(file, outputFileExtension))
            {
                logf("Error: File '%s' does not end in '%s'.", file, outputFileExtension);
                return false;
            }

            FileStream stream;

            try
            {
                stream = new FileStream(file);
                auto reader = new ProgramReader(stream);
                auto program = reader.read();

                foreach (mod; program.modules)
                {
                    FileStream file;
                    auto fileName = buildPath(outputDir, mod.y.name ~ inputFileExtension);

                    try
                    {
                        file = new FileStream(fileName, FileAccess.write, FileMode.truncate);
                        auto disasm = new ModuleDisassembler(file);

                        disasm.disassemble(mod.y);
                    }
                    catch (ErrnoException ex)
                    {
                        logf("Error: Could not write '%s': %s", fileName, ex.msg);
                        return false;
                    }
                    finally
                    {
                        if (file)
                            file.close();
                    }
                }
            }
            catch (ErrnoException ex)
            {
                logf("Error: Could not read '%s': %s", file, ex.msg);
                return false;
            }
            catch (ReaderException ex)
            {
                logf("Error: Could not load '%s': %s", file, ex.msg);
                return false;
            }
            finally
            {
                if (stream)
                    stream.close();
            }
        }

        return true;
    }
}
