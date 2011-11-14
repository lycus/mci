module mci.assembler.generation.functions;

import mci.core.container,
       mci.core.program,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.modules,
       mci.core.typing.cache,
       mci.assembler.parsing.ast,
       mci.assembler.generation.exception,
       mci.assembler.generation.modules,
       mci.assembler.generation.types;

public Function generateFunction(FunctionDeclarationNode node, Module module_, Program program)
in
{
    assert(node);
    assert(module_);
    assert(program);
}
body
{
    foreach (func; module_.functions)
        if (node.name.name == func.name)
            throw new GenerationException("Function " ~ module_.name ~ "/" ~ node.name.name ~ " already defined.", node.location);

    auto returnType = resolveType(node.returnType, module_, program);
    auto registers = new NoNullList!Register();
    auto parameters = new NoNullList!Parameter();

    foreach (param; node.parameters)
    {
        foreach (par; parameters)
            if (param.name.name == par.register.name)
                throw new GenerationException("Parameter " ~ param.name.name ~ " already defined.", param.location);

        auto reg = new Register(param.name.name, resolveType(param.type, module_, program));

        registers.add(reg);
        parameters.add(new Parameter(reg));
    }

    auto func = module_.createFunction(node.name.name, returnType, parameters, node.attributes, node.callingConvention);

    foreach (reg; registers)
        func.registers.add(reg);

    foreach (reg; node.registers)
    {
        foreach (register; func.registers)
            if (reg.name.name == register.name)
                throw new GenerationException("Register " ~ reg.name.name ~ " already defined.", reg.location);

        func.registers.add(new Register(reg.name.name, resolveType(reg.type, module_, program)));
    }

    foreach (block; node.blocks)
    {
        foreach (bb; func.blocks)
            if (block.name.name == bb.name)
                throw new GenerationException("Basic block " ~ block.name.name ~ " already defined.", block.location);

        // TODO: Emit instructions too.
        func.blocks.add(new BasicBlock(block.name.name));
    }

    return func;
}

public Function resolveFunction(FunctionReferenceNode node, Module module_, Program program)
in
{
    assert(node);
    assert(module_);
    assert(program);
}
body
{
    auto mod = node.moduleName ? resolveModule(node.moduleName, program) : module_;

    foreach (func; mod.functions)
        if (func.name == node.name.name)
            return func;

    throw new GenerationException("Unknown function " ~ mod.name ~ "/" ~ node.name.name ~ ".",
                                  node.location);
}
