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
        return resolveStructureType(structType, module_, program);
    else if (auto fpType = cast(FunctionPointerTypeReferenceNode)node)
        return resolveFunctionPointerType(fpType, module_, program);
    else if (auto ptrType = cast(PointerTypeReferenceNode)node)
        return program.typeCache.getPointerType(resolveType(ptrType.elementType, module_, program));
    else
        return program.typeCache.getType(null, (cast(CoreTypeReferenceNode)node).name.name);
}

public StructureType resolveStructureType(StructureTypeReferenceNode node, Module module_, Program program)
in
{
    assert(node);
    assert(module_);
    assert(program);
}
body
{
    // If no module is specified, default to the module the type reference is in.
    auto mod = node.moduleName ? resolveModule(node.moduleName, program) : module_;

    foreach (type; mod.types)
        if (type.name == node.name.name)
            return type;

    throw new GenerationException("Unknown type " ~ mod.name ~ "/" ~ node.name.name ~ ".",
                                  node.location);
}

public FunctionPointerType resolveFunctionPointerType(FunctionPointerTypeReferenceNode node, Module module_, Program program)
in
{
    assert(node);
    assert(module_);
    assert(program);
}
body
{
    auto returnType = resolveType(node.returnType, module_, program);
    auto parameterTypes = new NoNullList!Type();

    foreach (paramType; node.parameterTypes)
        parameterTypes.add(resolveType(paramType, module_, program));

    return program.typeCache.getFunctionPointerType(returnType, parameterTypes);
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
