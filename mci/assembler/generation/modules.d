module mci.assembler.generation.modules;

import mci.core.container,
       mci.core.code.modules,
       mci.assembler.parsing.ast,
       mci.assembler.generation.exception;

public Module resolveModule(ModuleReferenceNode node, ModuleManager manager)
in
{
    assert(node);
    assert(manager);
}
out (result)
{
    assert(result);
}
body
{
    if (auto mod = manager.modules.get(node.name.name))
        return *mod;

    throw new GenerationException("Unknown module " ~ node.name.name ~ ".", node.location);
}
