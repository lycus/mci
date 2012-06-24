module mci.compiler.clang.instructions;

import mci.compiler.clang.alu,
       mci.compiler.clang.arrays,
       mci.compiler.clang.control,
       mci.compiler.clang.generator,
       mci.compiler.clang.memory,
       mci.compiler.clang.misc,
       mci.core.code.instructions;

package void writeInstruction(ClangCGenerator generator, Instruction instruction)
in
{
    assert(generator);
    assert(instruction);
}
body
{
    switch (instruction.opCode.code)
    {
        default:
            generator.writer.writeifln("/* Unhandled opcode: %s */;", instruction.opCode.code);
            break;
    }
}
