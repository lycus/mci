module mci.assembler.generation.functions;

import std.conv,
       mci.core.container,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.modules,
       mci.core.code.opcodes,
       mci.core.typing.cache,
       mci.assembler.parsing.ast,
       mci.assembler.generation.exception,
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
    if (module_.functions.get(node.name.name))
        throw new GenerationException("Function " ~ module_.name ~ "/" ~ node.name.name ~ " already defined.", node.location);

    auto returnType = node.returnType ? resolveType(node.returnType, module_, manager) : null;
    auto func = new Function(module_, node.name.name, returnType, node.attributes);

    foreach (param; node.parameters)
        func.createParameter(resolveType(param.type, module_, manager));

    func.close();

    foreach (reg; node.registers)
    {
        if (func.registers.get(reg.name.name))
            throw new GenerationException("Register " ~ reg.name.name ~ " already defined.", reg.location);

        func.createRegister(reg.name.name, resolveType(reg.type, module_, manager));
    }

    foreach (block; node.blocks)
    {
        if (func.blocks.get(block.name.name))
            throw new GenerationException("Basic block " ~ block.name.name ~ " already defined.", block.location);

        func.createBasicBlock(block.name.name);
    }

    foreach (block; node.blocks)
    {
        auto bb = func.blocks.get(block.name.name);

        foreach (instrNode; block.instructions)
        {
            auto source1 = instrNode.source1 ? resolveRegister(instrNode.source1, func) : null;
            auto source2 = instrNode.source2 ? resolveRegister(instrNode.source2, func) : null;
            auto source3 = instrNode.source3 ? resolveRegister(instrNode.source3, func) : null;
            auto target = instrNode.target ? resolveRegister(instrNode.target, func) : null;

            mci.core.code.instructions.InstructionOperand operand;

            if (instrNode.operand)
            {
                auto instrOperand = instrNode.operand.operand;

                ReadOnlyIndexable!T generateArray(T)()
                {
                    auto values = new List!T();

                    foreach (literal; instrOperand.peek!ArrayLiteralNode().values)
                        values.add(to!T(literal.value));

                    return values;
                }

                final switch (instrNode.opCode.operandType)
                {
                    case OperandType.none:
                        assert(false);
                    case OperandType.int8:
                        operand = to!byte(instrOperand.peek!LiteralValueNode().value);
                        break;
                    case OperandType.uint8:
                        operand = to!ubyte(instrOperand.peek!LiteralValueNode().value);
                        break;
                    case OperandType.int16:
                        operand = to!short(instrOperand.peek!LiteralValueNode().value);
                        break;
                    case OperandType.uint16:
                        operand = to!ushort(instrOperand.peek!LiteralValueNode().value);
                        break;
                    case OperandType.int32:
                        operand = to!int(instrOperand.peek!LiteralValueNode().value);
                        break;
                    case OperandType.uint32:
                        operand = to!uint(instrOperand.peek!LiteralValueNode().value);
                        break;
                    case OperandType.int64:
                        operand = to!long(instrOperand.peek!LiteralValueNode().value);
                        break;
                    case OperandType.uint64:
                        operand = to!ulong(instrOperand.peek!LiteralValueNode().value);
                        break;
                    case OperandType.float32:
                        operand = to!float(instrOperand.peek!LiteralValueNode().value);
                        break;
                    case OperandType.float64:
                        operand = to!double(instrOperand.peek!LiteralValueNode().value);
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
                        operand = resolveBasicBlock(*instrOperand.peek!BasicBlockReferenceNode(), func);
                        break;
                    case OperandType.branch:
                        auto branch = *instrOperand.peek!BranchSelectorNode();
                        operand = tuple(resolveBasicBlock(branch.trueBlock, func), resolveBasicBlock(branch.falseBlock, func));
                        break;
                    case OperandType.type:
                        operand = resolveType(*instrOperand.peek!TypeReferenceNode(), module_, manager);
                        break;
                    case OperandType.field:
                        operand = resolveField(*instrOperand.peek!FieldReferenceNode(), module_, manager);
                        break;
                    case OperandType.function_:
                        operand = resolveFunction(*instrOperand.peek!FunctionReferenceNode(), module_, manager);
                        break;
                    case OperandType.selector:
                        auto regs = instrOperand.peek!RegisterSelectorNode().registers;
                        auto registers = new NoNullList!Register();

                        foreach (reg; regs)
                            registers.add(resolveRegister(reg, func));

                        operand = asReadOnlyIndexable(registers);
                        break;
                    case OperandType.ffi:
                        auto ffi = *instrOperand.peek!FFISignatureNode();

                        operand = new FFISignature(ffi.library.name, ffi.entryPoint.name, ffi.callingConvention);
                        break;
                }
            }

            bb.instructions.add(new Instruction(instrNode.opCode, operand, target, source1, source2, source3));
        }
    }

    if (!func.blocks.get(entryBlockName))
        throw new GenerationException("Function " ~ module_.name ~ "/" ~ node.name.name ~ " has no entry block.", node.location);

    return func;
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

    throw new GenerationException("Unknown function " ~ mod.name ~ "/" ~ node.name.name ~ ".", node.location);
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

    throw new GenerationException("Unknown register " ~ node.name.name ~ ".", node.location);
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

    throw new GenerationException("Unknown basic block " ~ node.name.name ~ ".", node.location);
}
