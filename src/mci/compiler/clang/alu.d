module mci.compiler.clang.alu;

import mci.compiler.clang.generator,
       mci.core.config,
       mci.core.code.instructions,
       mci.core.code.functions,
       mci.core.code.opcodes,
       mci.core.typing.members,
       mci.core.typing.types,
       mci.vm.memory.layout;

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
