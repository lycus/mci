module mci.compiler.clang.control;

import mci.compiler.clang.generator,
       mci.core.code.instructions,
       mci.core.code.opcodes;

package void writeTerminatorInstruction(ClangCGenerator generator, Instruction instruction)
in
{
    assert(generator);
    assert(instruction);
}
body
{
    switch (instruction.opCode.code)
    {
        case OperationCode.dead:
            generator.writer.writeiln("__builtin_unreachable();");
            break;
        case OperationCode.leave:
            generator.writer.writeiln("return;");
            break;
        case OperationCode.return_:
            generator.writer.writeifln("return reg__%s;", instruction.sourceRegister1.name);
            break;
        default:
            assert(false);
    }
}
