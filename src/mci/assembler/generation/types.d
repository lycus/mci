module mci.assembler.generation.types;

import std.conv,
       mci.core.common,
       mci.core.container,
       mci.core.math,
       mci.core.nullable,
       mci.core.analysis.utilities,
       mci.core.code.metadata,
       mci.core.code.modules,
       mci.core.typing.core,
       mci.core.typing.cache,
       mci.core.typing.types,
       mci.assembler.parsing.ast,
       mci.assembler.generation.exception,
       mci.assembler.generation.modules;

public StructureType generateType(TypeDeclarationNode node, Module module_)
in
{
    assert(node);
    assert(module_);
}
out (result)
{
    assert(result);
}
body
{
    if (auto type = module_.types.get(node.name.name))
        throw new GenerationException("Type " ~ type.toString() ~ " already defined.", node.location);

    uint alignment;

    if (node.alignment)
    {
        auto al = to!uint(node.alignment.value);

        if (al && !powerOfTwo(al))
            throw new GenerationException("Type alignment must be a power of two.", node.alignment.location);

        alignment = al;
    }

    auto type = new StructureType(module_, node.name.name, alignment);

    if (node.metadata)
        foreach (md; node.metadata.metadata)
            type.metadata.add(MetadataPair(md.key.name, md.value.name));

    return type;
}

public StructureMember generateMember(MemberDeclarationNode node, StructureType type, ModuleManager manager)
in
{
    assert(node);
    assert(type);
    assert(manager);
}
out (result)
{
    assert(result);
}
body
{
    auto fieldType = resolveType(node.type, type.module_, manager);

    if (auto struc = cast(StructureType)fieldType)
        if (type.hasCycle(struc))
            throw new GenerationException("Member " ~ type.toString() ~ ":'" ~ node.name.name ~ "' would create an infinite cycle.", node.location);

    return type.createMember(node.name.name, fieldType);
}

public Type resolveType(TypeReferenceNode node, Module module_, ModuleManager manager)
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
    return match(node,
                 (StructureTypeReferenceNode n) => resolveStructureType(n, module_, manager),
                 (FunctionPointerTypeReferenceNode n) => resolveFunctionPointerType(n, module_, manager),
                 (PointerTypeReferenceNode n) => getPointerType(resolveType(n.elementType, module_, manager)),
                 (ReferenceTypeReferenceNode n) => getReferenceType(cast(StructureType)resolveType(n.elementType, module_, manager)),
                 (ArrayTypeReferenceNode n) => getArrayType(resolveType(n.elementType, module_, manager)),
                 (VectorTypeReferenceNode n) => getVectorType(resolveType(n.elementType, module_, manager), to!uint(n.elements.value)),
                 (StaticArrayTypeReferenceNode n) => getStaticArrayType(resolveType(n.elementType, module_, manager), to!uint(n.elements.value)),
                 (Int8TypeReferenceNode n) => Int8Type.instance,
                 (UInt8TypeReferenceNode n) => UInt8Type.instance,
                 (Int16TypeReferenceNode n) => Int16Type.instance,
                 (UInt16TypeReferenceNode n) => UInt16Type.instance,
                 (Int32TypeReferenceNode n) => Int32Type.instance,
                 (UInt32TypeReferenceNode n) => UInt32Type.instance,
                 (Int64TypeReferenceNode n) => Int64Type.instance,
                 (UInt64TypeReferenceNode n) => UInt64Type.instance,
                 (NativeIntTypeReferenceNode n) => NativeIntType.instance,
                 (NativeUIntTypeReferenceNode n) => NativeUIntType.instance,
                 (Float32TypeReferenceNode n) => Float32Type.instance,
                 (Float64TypeReferenceNode n) => Float64Type.instance);
}

public StructureType resolveStructureType(StructureTypeReferenceNode node, Module module_, ModuleManager manager)
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
    // If no module is specified, default to the module the type reference is in.
    auto mod = node.moduleName ? resolveModule(node.moduleName, manager) : module_;

    if (auto type = mod.types.get(node.name.name))
        return *type;

    throw new GenerationException("Unknown type " ~ mod.toString() ~ "/'" ~ node.name.name ~ "'.", node.location);
}

public FunctionPointerType resolveFunctionPointerType(FunctionPointerTypeReferenceNode node, Module module_,
                                                      ModuleManager manager)
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
    auto returnType = node.returnType ? resolveType(node.returnType, module_, manager) : null;
    auto parameterTypes = new NoNullList!Type();

    foreach (paramType; node.parameterTypes)
        parameterTypes.add(resolveType(paramType, module_, manager));

    return getFunctionPointerType(node.callingConvention, returnType, parameterTypes);
}

public StructureMember resolveMember(MemberReferenceNode node, Module module_, ModuleManager manager)
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
    auto type = cast(StructureType)resolveType(node.typeName, module_, manager);

    if (auto field = type.members.get(node.name.name))
        return *field;

    throw new GenerationException("Unknown member " ~ type.toString() ~ ":'" ~ node.name.name ~ "'.", node.location);
}
