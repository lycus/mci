module mci.assembler.generation.types;

import std.conv,
       mci.core.common,
       mci.core.container,
       mci.core.nullable,
       mci.core.code.modules,
       mci.core.typing.core,
       mci.core.typing.cache,
       mci.core.typing.members,
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

    return new StructureType(module_, node.name.name, alignment);
}

public Field generateField(FieldDeclarationNode node, StructureType type, ModuleManager manager)
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

    return type.createField(node.name.name, fieldType, node.storage);
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
    if (auto structType = cast(StructureTypeReferenceNode)node)
        return resolveStructureType(structType, module_, manager);
    else if (auto fpType = cast(FunctionPointerTypeReferenceNode)node)
        return resolveFunctionPointerType(fpType, module_, manager);
    else if (auto ptrType = cast(PointerTypeReferenceNode)node)
        return getPointerType(resolveType(ptrType.elementType, module_, manager));
    else if (auto refType = cast(ReferenceTypeReferenceNode)node)
        return getReferenceType(cast(StructureType)resolveType(refType.elementType, module_, manager));
    else if (auto arrType = cast(ArrayTypeReferenceNode)node)
        return getArrayType(resolveType(arrType.elementType, module_, manager));
    else if (auto vecType = cast(VectorTypeReferenceNode)node)
    {
        auto elements = to!uint(vecType.elements.value);
        return getVectorType(resolveType(vecType.elementType, module_, manager), elements);
    }
    else
    {
        if (isType!Int8TypeReferenceNode(node))
            return Int8Type.instance;
        else if (isType!UInt8TypeReferenceNode(node))
            return UInt8Type.instance;
        else if (isType!Int16TypeReferenceNode(node))
            return Int16Type.instance;
        else if (isType!UInt16TypeReferenceNode(node))
            return UInt16Type.instance;
        else if (isType!Int32TypeReferenceNode(node))
            return Int32Type.instance;
        else if (isType!UInt32TypeReferenceNode(node))
            return UInt32Type.instance;
        else if (isType!Int64TypeReferenceNode(node))
            return Int64Type.instance;
        else if (isType!UInt64TypeReferenceNode(node))
            return UInt64Type.instance;
        else if (isType!NativeIntTypeReferenceNode(node))
            return NativeIntType.instance;
        else if (isType!NativeUIntTypeReferenceNode(node))
            return NativeUIntType.instance;
        else if (isType!Float32TypeReferenceNode(node))
            return Float32Type.instance;
        else
            return Float64Type.instance;
    }
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

public Field resolveField(FieldReferenceNode node, Module module_, ModuleManager manager)
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

    if (auto field = type.fields.get(node.name.name))
        return *field;

    throw new GenerationException("Unknown field " ~ type.toString() ~ ":'" ~ node.name.name ~ "'.", node.location);
}
