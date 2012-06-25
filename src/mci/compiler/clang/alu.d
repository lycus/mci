module mci.compiler.clang.alu;

import mci.compiler.clang.generator,
       mci.core.code.instructions,
       mci.core.code.opcodes;

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
            generator.writer.writeifln("reg__%s = %s;", instruction.targetRegister.name, instruction.operand);
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
        default:
            assert(false);
    }
}
