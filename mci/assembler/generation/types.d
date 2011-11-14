module mci.assembler.generation.types;

import std.conv,
       mci.core.container,
       mci.core.nullable,
       mci.core.program,
       mci.core.code.modules,
       mci.core.typing.cache,
       mci.core.typing.members,
       mci.core.typing.types,
       mci.assembler.parsing.ast,
       mci.assembler.generation.exception,
       mci.assembler.generation.modules;

public StructureType generateType(TypeDeclarationNode node, Module module_, TypeCache cache)
in
{
    assert(node);
    assert(module_);
    assert(cache);
}
body
{
    if (cache.getType(module_.name, node.name.name))
        throw new GenerationException("Type " ~ module_.name ~ "/" ~ node.name.name ~ " already defined.", node.location);

    auto packingSize = node.packingSize ? Nullable!uint(to!uint(node.packingSize.value)) : Nullable!uint();

    return cache.addStructureType(module_, node.name.name, node.attributes, node.layout, packingSize);
}

public Field generateField(FieldDeclarationNode node, StructureType type, Program program)
in
{
    assert(node);
    assert(type);
    assert(program);
}
body
{
    // FIXME: Detect duplicate field definitions.
    auto fieldType = resolveType(node.type, type.module_, program);
    auto offset = node.offset ? Nullable!uint(to!uint(node.offset.value)) : Nullable!uint();

    return type.createField(node.name.name, fieldType, node.attributes, offset);
}

public Type resolveType(TypeReferenceNode node, Module module_, Program program)
in
{
    assert(node);
    assert(module_);
    assert(program);
}
body
{
    if (auto structType = cast(StructureTypeReferenceNode)node)
    {
        // If no module is specified, default to the module the type reference is in.
        auto mod = structType.moduleName ? resolveModule(structType.moduleName, program) : module_;

        foreach (type; mod.types)
            if (type.name == structType.name.name)
                return type;

        throw new GenerationException("Unknown type " ~ mod.name ~ "/" ~ structType.name.name ~ ".",
                                      node.location);
    }
    else if (auto fpType = cast(FunctionPointerTypeReferenceNode)node)
    {
        auto returnType = resolveType(fpType.returnType, module_, program);
        auto parameterTypes = new NoNullList!Type();

        foreach (paramType; fpType.parameterTypes)
            parameterTypes.add(resolveType(paramType, module_, program));

        return program.typeCache.getFunctionPointerType(returnType, parameterTypes);
    }
    else if (auto ptrType = cast(PointerTypeReferenceNode)node)
        return program.typeCache.getPointerType(resolveType(ptrType.elementType, module_, program));
    else
        return program.typeCache.getType(null, (cast(CoreTypeReferenceNode)node).name.name);
}

public Field resolveField(FieldReferenceNode node, Module module_, Program program)
in
{
    assert(node);
    assert(module_);
    assert(program);
}
body
{
    auto type = cast(StructureType)resolveType(node.typeName, module_, program);

    foreach (field; type.fields)
        if (field.name == node.name.name)
            return field;

    throw new GenerationException("Unknown field " ~ type.module_.name ~ "/" ~ type.name ~ ":" ~ node.name.name ~ ".",
                                  node.location);
}
