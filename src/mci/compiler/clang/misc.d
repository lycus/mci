module mci.compiler.clang.misc;

import mci.compiler.clang.generator,
       mci.core.code.instructions,
       mci.core.code.opcodes;

package void writeMiscellaneousInstruction(ClangCGenerator generator, Instruction instruction)
in
{
    assert(generator);
    assert(instruction);
}
body
{
    switch (instruction.opCode.code)
    {
        case OperationCode.fence:
            generator.writer.writeiln("__sync_synchronize();");
            break;
        default:
            assert(false);
    }
}
