module mci.cli.tools.verifier;

import std.exception,
       std.path,
       mci.core.code.functions,
       mci.core.code.modules,
       mci.verifier.exception,
       mci.verifier.manager,
       mci.vm.intrinsics.declarations,
       mci.vm.io.exception,
       mci.vm.io.reader,
       mci.cli.main,
       mci.cli.tool;

public final class VerifierTool : Tool
{
    @property public string description()
    {
        return "Verify the validity of assembled modules.";
    }

    @property public string[] options()
    {
        return null;
    }

    public ubyte run(string[] args)
    {
        args = args[1 .. $];

        if (args.length == 0)
        {
            log("Error: No input modules given.");
            return 2;
        }

        string[] files;

        foreach (file; args)
        {
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

        foreach (file; args)
        {
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

        return 0;
    }
}
