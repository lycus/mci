module mci.assembler.generation.functions;

import std.algorithm,
       std.conv,
       std.traits,
       mci.core.container,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.metadata,
       mci.core.code.modules,
       mci.core.code.opcodes,
       mci.core.code.symbols,
       mci.core.typing.cache,
       mci.assembler.parsing.ast,
       mci.assembler.generation.data,
       mci.assembler.generation.exception,
       mci.assembler.generation.fields,
       mci.assembler.generation.modules,
       mci.assembler.generation.types;

public Function generateFunction(FunctionDeclarationNode node, Module module_, ModuleManager manager)
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
    if (auto func = module_.functions.get(node.name.name))
        throw new GenerationException("Function " ~ func.toString() ~ " already defined.", node.location);

    auto returnType = node.returnType ? resolveType(node.returnType, module_, manager) : null;
    auto func = new Function(module_, node.name.name, returnType, node.callingConvention, node.attributes);

    foreach (param; node.parameters)
    {
        auto p = func.createParameter(resolveType(param.type, module_, manager), param.attributes);

        if (param.metadata)
            foreach (md; param.metadata.metadata)
                p.metadata.add(MetadataPair(md.key.name, md.value.name));
    }

    func.close();

    if (node.metadata)
        foreach (md; node.metadata.metadata)
            func.metadata.add(MetadataPair(md.key.name, md.value.name));

    return func;
}

public void generateFunctionBody(FunctionDeclarationNode node, Function function_, Module module_, ModuleManager manager)
in
{
    assert(node);
    assert(function_);
    assert(module_);
    assert(manager);
}
body
{
    foreach (reg; node.registers)
    {
        if (auto existingReg = function_.registers.get(reg.name.name))
            throw new GenerationException("Register " ~ existingReg.toString() ~ " already defined.", reg.location);

        auto register = function_.createRegister(reg.name.name, resolveType(reg.type, module_, manager));

        if (reg.metadata)
            foreach (md; reg.metadata.metadata)
                register.metadata.add(MetadataPair(md.key.name, md.value.name));
    }

    foreach (block; node.blocks)
    {
        if (auto bb = function_.blocks.get(block.name.name))
            throw new GenerationException("Basic block " ~ bb.toString() ~ " already defined.", block.location);

        function_.createBasicBlock(block.name.name);
    }

    foreach (block; node.blocks)
    {
        auto bb = function_.blocks[block.name.name];

        if (block.unwindBlock)
            bb.unwindBlock = resolveBasicBlock(block.unwindBlock, function_);

        bb.close();

        if (block.metadata)
            foreach (md; block.metadata.metadata)
                bb.metadata.add(MetadataPair(md.key.name, md.value.name));
    }

    foreach (block; node.blocks)
    {
        auto bb = function_.blocks.get(block.name.name);

        foreach (instrNode; block.instructions)
        {
            auto source1 = instrNode.source1 ? resolveRegister(instrNode.source1, function_) : null;
            auto source2 = instrNode.source2 ? resolveRegister(instrNode.source2, function_) : null;
            auto source3 = instrNode.source3 ? resolveRegister(instrNode.source3, function_) : null;
            auto target = instrNode.target ? resolveRegister(instrNode.target, function_) : null;

            mci.core.code.instructions.InstructionOperand operand;

            if (instrNode.operand)
            {
                auto instrOperand = instrNode.operand.operand;

                T parse(T)(LiteralValueNode literal = null)
                {
                    auto node = literal ? literal : *instrOperand.peek!LiteralValueNode();
                    string value;
                    uint radix;

                    if (startsWith(node.value, "0x"))
                    {
                        value = node.value[2 .. $];
                        radix = 16;
                    }
                    else
                    {
                        value = node.value;
                        radix = 10;
                    }

                    static if (!isFloatingPoint!T)
                        return .parse!T(value, radix);
                    else
                        return .parse!T(value);
                }

                ReadOnlyIndexable!T generateArray(T)()
                {
                    auto values = new List!T();

                    foreach (literal; instrOperand.peek!ArrayLiteralNode().values)
                        values.add(parse!T(literal));

                    return values;
                }

                final switch (instrNode.opCode.operandType)
                {
                    case OperandType.none:
                        assert(false);
                    case OperandType.int8:
                        operand = parse!byte();
                        break;
                    case OperandType.uint8:
                        operand = parse!ubyte();
                        break;
                    case OperandType.int16:
                        operand = parse!short();
                        break;
                    case OperandType.uint16:
                        operand = parse!ushort();
                        break;
                    case OperandType.int32:
                        operand = parse!int();
                        break;
                    case OperandType.uint32:
                        operand = parse!uint();
                        break;
                    case OperandType.int64:
                        operand = parse!long();
                        break;
                    case OperandType.uint64:
                        operand = parse!ulong();
                        break;
                    case OperandType.float32:
                        operand = parse!float();
                        break;
                    case OperandType.float64:
                        operand = parse!double();
                        break;
                    case OperandType.int8Array:
                        operand = generateArray!byte();
                        break;
                    case OperandType.uint8Array:
                        operand = generateArray!ubyte();
                        break;
                    case OperandType.int16Array:
                        operand = generateArray!short();
                        break;
                    case OperandType.uint16Array:
                        operand = generateArray!ushort();
                        break;
                    case OperandType.int32Array:
                        operand = generateArray!int();
                        break;
                    case OperandType.uint32Array:
                        operand = generateArray!uint();
                        break;
                    case OperandType.int64Array:
                        operand = generateArray!long();
                        break;
                    case OperandType.uint64Array:
                        operand = generateArray!ulong();
                        break;
                    case OperandType.float32Array:
                        operand = generateArray!float();
                        break;
                    case OperandType.float64Array:
                        operand = generateArray!double();
                        break;
                    case OperandType.label:
                        operand = resolveBasicBlock(*instrOperand.peek!BasicBlockReferenceNode(), function_);
                        break;
                    case OperandType.branch:
                        auto branch = *instrOperand.peek!BranchSelectorNode();
                        operand = tuple(resolveBasicBlock(branch.trueBlock, function_), resolveBasicBlock(branch.falseBlock, function_));
                        break;
                    case OperandType.type:
                        operand = resolveType(*instrOperand.peek!TypeReferenceNode(), module_, manager);
                        break;
                    case OperandType.member:
                        operand = resolveMember(*instrOperand.peek!MemberReferenceNode(), module_, manager);
                        break;
                    case OperandType.globalField:
                        operand = resolveGlobalField(*instrOperand.peek!GlobalFieldReferenceNode(), module_, manager);
                        break;
                    case OperandType.threadField:
                        operand = resolveThreadField(*instrOperand.peek!ThreadFieldReferenceNode(), module_, manager);
                        break;
                    case OperandType.function_:
                        operand = resolveFunction(*instrOperand.peek!FunctionReferenceNode(), module_, manager);
                        break;
                    case OperandType.selector:
                        auto regs = instrOperand.peek!RegisterSelectorNode().registers;
                        auto registers = new NoNullList!Register();

                        foreach (reg; regs)
                            registers.add(resolveRegister(reg, function_));

                        operand = asReadOnlyIndexable(registers);
                        break;
                    case OperandType.foreignSymbol:
                        auto ff = *instrOperand.peek!ForeignSymbolNode();

                        operand = new ForeignSymbol(ff.library.name, ff.symbol.name);
                        break;
                    case OperandType.dataBlock:
                        operand = resolveDataBlock(*instrOperand.peek!DataBlockReferenceNode(), module_, manager);
                        break;
                }
            }

            auto instr = bb.stream.append(instrNode.opCode, instrNode.attributes, operand, target, source1, source2, source3);

            if (instrNode.metadata)
                foreach (md; instrNode.metadata.metadata)
                    instr.metadata.add(MetadataPair(md.key.name, md.value.name));
        }
    }
}

public Function resolveFunction(FunctionReferenceNode node, Module module_, ModuleManager manager)
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

    if (auto func = mod.functions.get(node.name.name))
        return *func;

    throw new GenerationException("Unknown function " ~ mod.toString() ~ "/'" ~ node.name.name ~ "'.", node.location);
}

public Register resolveRegister(RegisterReferenceNode node, Function function_)
in
{
    assert(node);
    assert(function_);
}
out (result)
{
    assert(result);
}
body
{
    if (auto reg = function_.registers.get(node.name.name))
        return *reg;

    throw new GenerationException("Unknown register '" ~ node.name.name ~ "'.", node.location);
}

public BasicBlock resolveBasicBlock(BasicBlockReferenceNode node, Function function_)
in
{
    assert(node);
    assert(function_);
}
out (result)
{
    assert(result);
}
body
{
    if (auto bb = function_.blocks.get(node.name.name))
        return *bb;

    throw new GenerationException("Unknown basic block '" ~ node.name.name ~ "'.", node.location);
}
