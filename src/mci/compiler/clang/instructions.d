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
            writeConstantLoadInstruction(generator, instruction);
            break;
        default:
            generator.writer.writeifln("/* Unhandled opcode: %s */;", instruction.opCode.name);
            break;
    }
}
