module mci.assembler.generation.functions;

import std.conv,
       mci.core.container,
       mci.core.program,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.modules,
       mci.core.code.opcodes,
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
out (result)
{
    assert(result);
}
body
{
    if (module_.functions.get(node.name.name))
        throw new GenerationException("Function " ~ module_.name ~ "/" ~ node.name.name ~ " already defined.", node.location);

    auto returnType = resolveType(node.returnType, module_, program);
    auto func = new Function(module_, node.name.name, returnType, node.attributes, node.callingConvention);

    foreach (param; node.parameters)
        func.createParameter(resolveType(param.type, module_, program));

    func.close();

    foreach (reg; node.registers)
    {
        if (func.registers.get(reg.name.name))
            throw new GenerationException("Register " ~ reg.name.name ~ " already defined.", reg.location);

        func.createRegister(reg.name.name, resolveType(reg.type, module_, program));
    }

    foreach (block; node.blocks)
    {
        if (func.blocks.get(block.name.name))
            throw new GenerationException("Basic block " ~ block.name.name ~ " already defined.", block.location);

        auto bb = func.createBasicBlock(block.name.name);

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
                    case OperandType.bytes:
                        auto bytes = new List!ubyte();

                        foreach (literal; instrOperand.peek!ByteArrayLiteralNode().values)
                            bytes.add(to!ubyte(literal.value));

                        operand = asCountable(bytes);
                        break;
                    case OperandType.label:
                        operand = resolveBasicBlock(*instrOperand.peek!BasicBlockReferenceNode(), func);
                        break;
                    case OperandType.type:
                        operand = resolveType(*instrOperand.peek!TypeReferenceNode(), module_, program);
                        break;
                    case OperandType.structure:
                        operand = resolveStructureType(*instrOperand.peek!StructureTypeReferenceNode(), module_, program);
                        break;
                    case OperandType.field:
                        operand = resolveField(*instrOperand.peek!FieldReferenceNode(), module_, program);
                        break;
                    case OperandType.function_:
                        operand = resolveFunction(*instrOperand.peek!FunctionReferenceNode(), module_, program);
                        break;
                    case OperandType.signature:
                        operand = resolveFunctionPointerType(*instrOperand.peek!FunctionPointerTypeReferenceNode(), module_, program);
                        break;
                    case OperandType.selector:
                        auto regs = instrOperand.peek!RegisterSelectorNode().registers;
                        auto registers = new NoNullList!Register();

                        foreach (reg; regs)
                            registers.add(resolveRegister(reg, func));

                        operand = asCountable(registers);
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

public Function resolveFunction(FunctionReferenceNode node, Module module_, Program program)
in
{
    assert(node);
    assert(module_);
    assert(program);
}
out (result)
{
    assert(result);
}
body
{
    auto mod = node.moduleName ? resolveModule(node.moduleName, program) : module_;

    if (auto func = mod.functions.get(node.name.name))
        return *func;

    throw new GenerationException("Unknown function " ~ mod.name ~ "/" ~ node.name.name ~ ".",
                                  node.location);
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
