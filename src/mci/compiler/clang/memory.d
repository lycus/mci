module mci.compiler.clang.memory;

import mci.compiler.clang.generator,
       mci.core.code.instructions,
       mci.core.code.opcodes;

package void writeMemoryAliasInstruction(ClangCGenerator generator, Instruction instruction)
in
{
    assert(generator);
    assert(instruction);
}
body
{
    switch (instruction.opCode.code)
    {
        case OperationCode.memGet:
            generator.writer.write("reg__%s = *reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name);
            break;
        case OperationCode.memSet:
            generator.writer.write("*reg__%s = reg__%s;", instruction.sourceRegister1.name, instruction.sourceRegister2.name);
            break;
        case OperationCode.memAddr:
            generator.writer.write("reg__%s = &reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name);
            break;
        default:
            assert(false);
    }
}
