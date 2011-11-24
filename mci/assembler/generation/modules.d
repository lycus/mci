module mci.assembler.generation.modules;

import mci.core.container,
       mci.core.program,
       mci.core.code.modules,
       mci.assembler.parsing.ast,
       mci.assembler.generation.exception;

public Module resolveModule(ModuleReferenceNode node, Program program)
in
{
    assert(node);
    assert(program);
}
out (result)
{
    assert(result);
}
body
{
    if (auto mod = program.modules.get(node.name.name))
        return *mod;

    throw new GenerationException("Unknown module " ~ node.name.name ~ ".", node.location);
}
