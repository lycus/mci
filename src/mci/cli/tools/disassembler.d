module mci.cli.tools.disassembler;

import std.getopt,
       std.path,
       mci.assembler.disassembly.modules,
       mci.core.exception,
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
    @property public string name() pure nothrow
    {
        return "disasm";
    }

    @property public string description() pure nothrow
    {
        return "Disassemble an assembled module into IAL code.";
    }

    @property public string[] options() pure nothrow
    {
        return ["\t--output=<file>\t\t-o <file>\tSpecify module output file."];
    }

    public ubyte run(string[] args)
    {
        string output = "out.ial";

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

        if (args.length != 1)
        {
            log("Error: Exactly one input module must be given.");
            return 2;
        }

        if (output[0] == '.' && output.length <= inputFileExtension.length + 1)
        {
            logf("Error: Output file '%s' has no name part.", output);
            return 2;
        }

        if (extension(output) != inputFileExtension)
        {
            logf("Error: Output file '%s' does not end in '%s'.", output, inputFileExtension);
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

            stream = new FileStream(output, FileMode.truncate);
            auto disasm = new ModuleDisassembler(stream);

            disasm.disassemble(mod);
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
