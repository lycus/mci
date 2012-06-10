module mci.cli.tools.lint;

import std.exception,
       std.path,
       mci.cli.main,
       mci.cli.tool,
       mci.core.container,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.modules,
       mci.verifier.exception,
       mci.verifier.lint,
       mci.verifier.manager,
       mci.vm.intrinsics.declarations,
       mci.vm.io.exception,
       mci.vm.io.reader;

public final class LintTool : Tool
{
    @property public string name() pure nothrow
    {
        return "lint";
    }

    @property public string description() pure nothrow
    {
        return "Perform various static correctness analyses on assembled modules.";
    }

    @property public string[] options() pure nothrow
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

        ubyte code;

        foreach (file; args)
        {
            Module mod;
            Function currentFunc;

            try
            {
                auto manager = new ModuleManager();
                manager.attach(intrinsicModule);

                auto reader = new ModuleReader(manager);
                mod = reader.load(file);

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
                logf("Error: Verification failed in function %s:", currentFunc);
                log(ex.msg);

                if (ex.instruction)
                {
                    log();
                    logf("The invalid instruction was (index %s in block %s):", findIndex(ex.instruction.block.stream, ex.instruction),
                         ex.instruction.block);
                    log(ex.instruction);
                }

                return 1;
            }

            auto linter = new Linter();

            addRange(linter.passes, standardPasses);

            foreach (func; filter(mod.functions, (Tuple!(string, Function) tup) => !!(tup.y.attributes & FunctionAttributes.ssa)))
            {
                auto msgs = linter.lint(func.y);

                if (!msgs.empty)
                {
                    code = 1;

                    logf("Messages for function %s:", func.y);
                    log();
                }

                foreach (msg; msgs)
                {
                    logf("Instruction (index %s in block %s): %s", findIndex(msg.instruction.block.stream, msg.instruction), msg.instruction.block,
                         msg.instruction);
                    logf("Message: %s", msg.message);
                }

                if (!msgs.empty)
                    log();
            }
        }

        return code;
    }
}
