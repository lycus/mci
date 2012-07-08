module mci.compiler.clang.instructions;

import mci.compiler.clang.alu,
       mci.compiler.clang.arrays,
       mci.compiler.clang.control,
       mci.compiler.clang.generator,
       mci.compiler.clang.memory,
       mci.compiler.clang.misc,
       mci.core.code.instructions,
       mci.core.code.opcodes;

package void writeInstruction(ClangCGenerator generator, Instruction instruction)
in
{
    assert(generator);
    assert(instruction);
}
body
{
    generator.writer.writeifln("// %s;", instruction);

    if (instruction.opCode.type == OpCodeType.controlFlow)
    {
        writeTerminatorInstruction(generator, instruction);
        return;
    }

    switch (instruction.opCode.code)
    {
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
        case OperationCode.loadFunc:
        case OperationCode.loadNull:
        case OperationCode.loadSize:
        case OperationCode.loadAlign:
        case OperationCode.loadOffset:
            writeConstantLoadInstruction(generator, instruction);
            break;
        case OperationCode.ariAdd:
        case OperationCode.ariSub:
        case OperationCode.ariMul:
        case OperationCode.ariDiv:
        case OperationCode.ariRem:
        case OperationCode.ariNeg:
            writeArithmeticInstruction(generator, instruction);
            break;
        case OperationCode.bitOr:
        case OperationCode.bitXOr:
        case OperationCode.bitAnd:
        case OperationCode.bitNeg:
            writeBitwiseInstruction(generator, instruction);
            break;
        case OperationCode.not:
        case OperationCode.shL:
        case OperationCode.shR:
        case OperationCode.roL:
        case OperationCode.roR:
        case OperationCode.conv:
            writeALUInstruction(generator, instruction);
            break;
        case OperationCode.cmpEq:
        case OperationCode.cmpNEq:
        case OperationCode.cmpGT:
        case OperationCode.cmpLT:
        case OperationCode.cmpGTEq:
        case OperationCode.cmpLTEq:
            writeComparisonInstruction(generator, instruction);
            break;
        case OperationCode.memAlloc:
        case OperationCode.memNew:
        case OperationCode.memFree:
        case OperationCode.memSAlloc:
        case OperationCode.memSNew:
        case OperationCode.memPin:
        case OperationCode.memUnpin:
            writeMemoryManagementInstruction(generator, instruction);
            break;
        case OperationCode.memGet:
        case OperationCode.memSet:
        case OperationCode.memAddr:
            writeMemoryAliasInstruction(generator, instruction);
            break;
        case OperationCode.nop:
        case OperationCode.comment:
        case OperationCode.fence:
            writeMiscellaneousInstruction(generator, instruction);
            break;
        default:
            generator.writer.writeifln("/* Unhandled opcode: %s */;", instruction.opCode.name);
            break;
    }
}
