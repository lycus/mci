module mci.cli.tools.disassembler;

import std.algorithm,
       std.exception,
       std.getopt,
       std.path,
       mci.assembler.disassembly.modules,
       mci.core.io,
       mci.core.code.modules,
       mci.vm.intrinsics.declarations,
       mci.vm.io.exception,
       mci.vm.io.reader,
       mci.cli.main,
       mci.cli.tool,
       mci.cli.tools.assembler;

public final class DisassemblerTool : Tool
{
    @property public string description()
    {
        return "Disassemble an assembled module into IAL code.";
    }

    @property public string[] options()
    {
        return ["\t--output=<file>\t\t-o <file>\tSpecify module output file."];
    }

    public bool run(string[] args)
    {
        string output = "out.mci";

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
            return false;
        }

        if (args.length == 0)
        {
            log("Error: No input modules given.");
            return false;
        }

        if (output.length <= inputFileExtension.length)
        {
            logf("Error: Output file '%s' has no name part.", output);
            return false;
        }

        if (extension(output) != inputFileExtension)
        {
            logf("Error: Output file '%s' does not end in '%s'.", output, inputFileExtension);
            return false;
        }

        foreach (file; args)
        {
            if (file.length <= moduleFileExtension.length)
            {
                logf("Error: Input module '%s' has no name part.", file);
                return false;
            }

            if (extension(file) != moduleFileExtension)
            {
                logf("Error: Input module '%s' does not end in '%s'.", file, moduleFileExtension);
                return false;
            }

            FileStream stream;

            try
            {
                auto manager = new ModuleManager();
                manager.attach(intrinsicModule);

                auto reader = new ModuleReader(manager);
                auto mod = reader.load(file);
                stream = new FileStream(output, FileAccess.write, FileMode.truncate);
                auto disasm = new ModuleDisassembler(stream);

                disasm.disassemble(mod);
            }
            catch (ErrnoException ex)
            {
                logf("Error: Could not access '%s': %s", file, ex.msg);
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
