module mci.compiler.clang.control;

import mci.compiler.clang.generator,
       mci.core.container,
       mci.core.tuple,
       mci.core.code.functions,
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
        case OperationCode.jump:
            generator.writer.writeifln("goto block__%s;", instruction.operand.peek!BasicBlock().name);
            break;
        case OperationCode.jumpCond:
            generator.writer.writeifln("if (reg__%s)", instruction.sourceRegister1.name);
            generator.writer.indent();

            generator.writer.writeifln("goto block__%s;", instruction.operand.peek!(Tuple!(BasicBlock, BasicBlock)).x.name);

            generator.writer.dedent();
            generator.writer.writeiln("else");
            generator.writer.indent();

            generator.writer.writeifln("goto block__%s;", instruction.operand.peek!(Tuple!(BasicBlock, BasicBlock)).y.name);

            generator.writer.dedent();
            break;
        case OperationCode.raw:
            generator.writer.writei("asm(\".byte ");

            auto bytes = *instruction.operand.peek!(ReadOnlyIndexable!ubyte)();

            foreach (i, val; bytes)
            {
                generator.writer.write("0x%x", i);

                if (i < bytes.count - 1)
                    generator.writer.write(", ");
            }

            generator.writer.writeln("\");");
            break;
        default:
            assert(false);
    }
}
