module mci.assembler.generation.fields;

import mci.core.code.fields,
       mci.core.code.modules,
       mci.assembler.generation.exception,
       mci.assembler.generation.modules,
       mci.assembler.generation.types,
       mci.assembler.parsing.ast;

public GlobalField generateGlobalField(GlobalFieldDeclarationNode node, Module module_, ModuleManager manager)
in
{
    assert(node);
    assert(module_);
    assert(manager);
}
out (result)
{
    assert(result);
}
body
{
    if (auto fld = module_.globalFields.get(node.name.name))
        throw new GenerationException("Global field " ~ fld.toString() ~ " already defined.", node.location);

    return new GlobalField(module_, node.name.name, resolveType(node.type, module_, manager));
}

public ThreadField generateThreadField(ThreadFieldDeclarationNode node, Module module_, ModuleManager manager)
in
{
    assert(node);
    assert(module_);
    assert(manager);
}
out (result)
{
    assert(result);
}
body
{
    if (auto fld = module_.threadFields.get(node.name.name))
        throw new GenerationException("Thread field " ~ fld.toString() ~ " already defined.", node.location);

    return new ThreadField(module_, node.name.name, resolveType(node.type, module_, manager));
}

public GlobalField resolveGlobalField(GlobalFieldReferenceNode node, Module module_, ModuleManager manager)
in
{
    assert(node);
    assert(module_);
    assert(manager);
}
out (result)
{
    assert(result);
}
body
{
    auto mod = node.moduleName ? resolveModule(node.moduleName, manager) : module_;

    if (auto field = mod.globalFields.get(node.name.name))
        return *field;

    throw new GenerationException("Unknown global field " ~ mod.toString() ~ "/'" ~ node.name.name ~ "'.", node.location);
}

public ThreadField resolveThreadField(ThreadFieldReferenceNode node, Module module_, ModuleManager manager)
in
{
    assert(node);
    assert(module_);
    assert(manager);
}
out (result)
{
    assert(result);
}
body
{
    auto mod = node.moduleName ? resolveModule(node.moduleName, manager) : module_;

    if (auto field = mod.threadFields.get(node.name.name))
        return *field;

    throw new GenerationException("Unknown thread field " ~ mod.toString() ~ "/'" ~ node.name.name ~ "'.", node.location);
}
