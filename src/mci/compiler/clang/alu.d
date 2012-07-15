module mci.compiler.clang.alu;

import std.math,
       mci.compiler.clang.generator,
       mci.compiler.clang.types,
       mci.core.common,
       mci.core.config,
       mci.core.code.instructions,
       mci.core.code.functions,
       mci.core.code.opcodes,
       mci.core.typing.members,
       mci.core.typing.types,
       mci.vm.memory.layout;

private string stringifyConstant(InstructionOperand operand)
in
{
    assert(operand.hasValue);
}
body
{
    if (auto f = operand.peek!float())
    {
        if (isInfinity(*f))
        {
            if (signbit(*f))
                return "-__builtin_inff()";
            else
                return "__builtin_inff()";
        }
        else if (isNaN(*f))
            return "__builtin_nanf(\"\")";
    }
    else if (auto d = operand.peek!double())
    {
        if (isInfinity(*d))
        {
            if (signbit(*d))
                return "-__builtin_inf()";
            else
                return "__builtin_inf()";
        }
        else if (isNaN(*d))
            return "__builtin_nan(\"\")";
    }

    return operand.toString();
}

package void writeConstantLoadInstruction(ClangCGenerator generator, Instruction instruction)
in
{
    assert(generator);
    assert(instruction);
}
body
{
    switch (instruction.opCode.code)
    {
        case OperationCode.copy:
            generator.writer.writeifln("reg__%s = reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name);
            break;
        case OperationCode.loadI8:
        case OperationCode.loadUI8:
        case OperationCode.loadI16:
        case OperationCode.loadUI16:
        case OperationCode.loadI32:
        case OperationCode.loadUI32:
        case OperationCode.loadI64:
        case OperationCode.loadUI64:
        case OperationCode.loadF32:
        case OperationCode.loadF64:
            generator.writer.writeifln("reg__%s = %s;", instruction.targetRegister.name, stringifyConstant(instruction.operand));
            break;
        case OperationCode.loadI8A:
        case OperationCode.loadUI8A:
        case OperationCode.loadI16A:
        case OperationCode.loadUI16A:
        case OperationCode.loadI32A:
        case OperationCode.loadUI32A:
        case OperationCode.loadI64A:
        case OperationCode.loadUI64A:
        case OperationCode.loadF32A:
        case OperationCode.loadF64A:
            assert(false);
        case OperationCode.loadFunc:
            auto func = instruction.operand.peek!Function();

            generator.writer.writeifln("reg__%s = &%s;", instruction.targetRegister.name, func.module_.name ~ "__" ~ func.name);
            break;
        case OperationCode.loadNull:
            generator.writer.writeiln("reg__%s = 0;", instruction.targetRegister.name);
            break;
        case OperationCode.loadSize:
            generator.writer.writeifln("reg__%s = %s;", instruction.targetRegister.name, computeSize(*instruction.operand.peek!Type(), is32Bit));
            break;
        case OperationCode.loadAlign:
            generator.writer.writeifln("reg__%s = %s;", instruction.targetRegister.name, computeAlignment(*instruction.operand.peek!Type(), is32Bit));
            break;
        case OperationCode.loadOffset:
            generator.writer.writeifln("reg__%s = %s;", instruction.targetRegister.name, computeOffset(*instruction.operand.peek!Field(), is32Bit));
            break;
        default:
            assert(false);
    }
}

package void writeArithmeticInstruction(ClangCGenerator generator, Instruction instruction)
in
{
    assert(generator);
    assert(instruction);
}
body
{
    switch (instruction.opCode.code)
    {
        case OperationCode.ariAdd:
            generator.writer.writeifln("reg__%s = reg__%s + reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name,
                                       instruction.sourceRegister2.name);
            break;
        case OperationCode.ariSub:
            generator.writer.writeifln("reg__%s = reg__%s - reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name,
                                       instruction.sourceRegister2.name);
            break;
        case OperationCode.ariMul:
            generator.writer.writeifln("reg__%s = reg__%s * reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name,
                                       instruction.sourceRegister2.name);
            break;
        case OperationCode.ariDiv:
            generator.writer.writeifln("reg__%s = reg__%s / reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name,
                                       instruction.sourceRegister2.name);
            break;
        case OperationCode.ariRem:
            generator.writer.writeifln("reg__%s = reg__%s %% reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name,
                                       instruction.sourceRegister2.name);
            break;
        case OperationCode.ariNeg:
            generator.writer.writeifln("reg__%s = -reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name);
            break;
        default:
            assert(false);
    }
}

package void writeBitwiseInstruction(ClangCGenerator generator, Instruction instruction)
in
{
    assert(generator);
    assert(instruction);
}
body
{
    switch (instruction.opCode.code)
    {
        case OperationCode.bitOr:
            generator.writer.writeifln("reg__%s = reg__%s | reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name,
                                       instruction.sourceRegister2.name);
            break;
        case OperationCode.bitXOr:
            generator.writer.writeifln("reg__%s = reg__%s ^ reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name,
                                       instruction.sourceRegister2.name);
            break;
        case OperationCode.bitAnd:
            generator.writer.writeifln("reg__%s = reg__%s & reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name,
                                       instruction.sourceRegister2.name);
            break;
        case OperationCode.bitNeg:
            generator.writer.writeifln("reg__%s = ~reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name);
            break;
        default:
            assert(false);
    }
}

package void writeALUInstruction(ClangCGenerator generator, Instruction instruction)
in
{
    assert(generator);
    assert(instruction);
}
body
{
    switch (instruction.opCode.code)
    {
        case OperationCode.not:
            generator.writer.writeifln("reg__%s = !reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name);
            break;
        case OperationCode.shL:
            generator.writer.writeifln("reg__%s = reg__%s << reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name,
                                       instruction.sourceRegister2.name);
            break;
        case OperationCode.shR:
            generator.writer.writeifln("reg__%s = reg__%s >> reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name,
                                       instruction.sourceRegister2.name);
            break;
        case OperationCode.roL:
            auto size = computeSize(instruction.targetRegister.type, is32Bit) * 8;

            generator.writer.writeifln("reg__%s = reg__%s << reg__%s | reg__%s >> %s - reg__%s;", instruction.targetRegister.name,
                                       instruction.sourceRegister1.name, instruction.sourceRegister2.name, instruction.sourceRegister1.name,
                                       size, instruction.sourceRegister2.name);
            break;
        case OperationCode.roR:
            auto size = computeSize(instruction.targetRegister.type, is32Bit) * 8;

            generator.writer.writeifln("reg__%s = reg__%s >> reg__%s | reg__%s << %s - reg__%s;", instruction.targetRegister.name,
                                       instruction.sourceRegister1.name, instruction.sourceRegister2.name, instruction.sourceRegister1.name,
                                       size, instruction.sourceRegister2.name);
            break;
        case OperationCode.conv:
            generator.writer.write("reg__%s = (%s)reg__%s;", instruction.targetRegister.name, typeToString(generator, instruction.targetRegister.type),
                                   instruction.sourceRegister1.name);
            break;
        default:
            assert(false);
    }
}

package void writeComparisonInstruction(ClangCGenerator generator, Instruction instruction)
in
{
    assert(generator);
    assert(instruction);
}
body
{
    switch (instruction.opCode.code)
    {
        case OperationCode.cmpEq:
            generator.writer.writeifln("reg__%s = reg__%s == reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name,
                                       instruction.sourceRegister2.name);
            break;
        case OperationCode.cmpNEq:
            generator.writer.writeifln("reg__%s = reg__%s != reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name,
                                       instruction.sourceRegister2.name);
            break;
        case OperationCode.cmpGT:
            generator.writer.writeifln("reg__%s = reg__%s > reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name,
                                       instruction.sourceRegister2.name);
            break;
        case OperationCode.cmpLT:
            generator.writer.writeifln("reg__%s = reg__%s < reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name,
                                       instruction.sourceRegister2.name);
            break;
        case OperationCode.cmpGTEq:
            generator.writer.writeifln("reg__%s = reg__%s >= reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name,
                                       instruction.sourceRegister2.name);
            break;
        case OperationCode.cmpLTEq:
            generator.writer.writeifln("reg__%s = reg__%s <= reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name,
                                       instruction.sourceRegister2.name);
            break;
        default:
            assert(false);
    }
}
