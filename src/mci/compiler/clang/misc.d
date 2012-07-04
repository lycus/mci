module mci.compiler.clang.misc;

import mci.compiler.clang.generator,
       mci.core.container,
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
        case OperationCode.nop:
            generator.writer.writeiln(";");
            break;
        case OperationCode.comment:
            generator.writer.writeifln("/* %s */", cast(string)instruction.operand.peek!(ReadOnlyIndexable!ubyte)().toArray());
            break;
        case OperationCode.fence:
            generator.writer.writeiln("__sync_synchronize();");
            break;
        default:
            assert(false);
    }
}
