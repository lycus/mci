module mci.compiler.clang.memory;

import mci.compiler.clang.generator,
       mci.core.config,
       mci.core.code.instructions,
       mci.core.code.opcodes,
       mci.core.typing.types,
       mci.vm.memory.layout;

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
            generator.writer.writeifln("reg__%s = *reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name);
            break;
        case OperationCode.memSet:
            generator.writer.writeifln("*reg__%s = reg__%s;", instruction.sourceRegister1.name, instruction.sourceRegister2.name);
            break;
        case OperationCode.memAddr:
            generator.writer.writeifln("reg__%s = &reg__%s;", instruction.targetRegister.name, instruction.sourceRegister1.name);
            break;
        default:
            assert(false);
    }
}

package void writeMemoryManagementInstruction(ClangCGenerator generator, Instruction instruction)
in
{
    assert(generator);
    assert(instruction);
}
body
{
    switch (instruction.opCode.code)
    {
        case OperationCode.memAlloc:
        case OperationCode.memNew:
        case OperationCode.memFree:
        case OperationCode.memSAlloc:
            generator.writer.writeifln("if (reg__%s)", instruction.sourceRegister1.name);
            generator.writer.indent();

            generator.writer.writeifln("reg__%s = __builtin_alloca(reg__%s * %s);", instruction.targetRegister.name, instruction.sourceRegister1.name,
                                       computeSize((cast(PointerType)instruction.targetRegister.type).elementType, is32Bit));

            generator.writer.dedent();
            generator.writer.writeiln("else");
            generator.writer.indent();

            generator.writer.writeifln("reg__%s = 0;", instruction.targetRegister.name);

            generator.writer.dedent();
            break;
        case OperationCode.memSNew:
            generator.writer.writeifln("reg__%s = __builtin_alloca(%s);", instruction.targetRegister.name,
                                       computeSize((cast(PointerType)instruction.targetRegister.type).elementType, is32Bit));
            break;
        case OperationCode.memPin:
        case OperationCode.memUnpin:
        default:
            assert(false);
    }
}
