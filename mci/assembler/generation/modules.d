module mci.assembler.generation.modules;

import mci.core.program,
       mci.core.code.modules,
       mci.assembler.parsing.ast,
       mci.assembler.generation.exception;

public Module resolveModule(ModuleReferenceNode node, Program program)
in
{
    assert(node);
    assert(program);
}
body
{
    foreach (mod; program.modules)
        if (mod.name == node.name.name)
            return mod;

    throw new GenerationException("Unknown module " ~ node.name.name ~ ".", node.location);
}
