module mci.compiler.clang.functions;

import std.conv,
       mci.compiler.clang.generator,
       mci.compiler.clang.instructions,
       mci.compiler.clang.types,
       mci.core.common,
       mci.core.config,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.typing.types;

package void writeFunction(ClangCGenerator generator, Function function_)
in
{
    assert(generator);
    assert(function_);
}
body
{
    // Clang's const attribute means what our pure attribute does.
    if (function_.attributes & FunctionAttributes.pure_)
        generator.writer.writeln("__attribute__((const))");

    if (function_.attributes & FunctionAttributes.noOptimization)
        generator.writer.writeln("__attribute__((optimize(0)))");

    if (function_.attributes & FunctionAttributes.noInlining)
        generator.writer.writeln("__attribute__((noinline))");

    static if (architecture == Architecture.x86 && is32Bit)
    {
        switch (function_.callingConvention)
        {
            case CallingConvention.cdecl:
                generator.writer.write("__attribute__((cdecl)) ");
                break;
            case CallingConvention.stdCall:
                generator.writer.write("__attribute__((stdcall)) ");
                break;
            default:
                break;
        }
    }

    auto name = function_.module_.name ~ "__" ~ function_.name;

    generator.writer.write(typeToString(function_.returnType, name));

    // If the function returns a function pointer, the above
    // typeToString call already printed the return type and name.
    if (!function_.returnType || !cast(FunctionPointerType)function_.returnType)
        generator.writer.writef(" %s", name);

    generator.writer.write("(");

    foreach (i, param; function_.parameters)
    {
        auto paramName = "param__" ~ to!string(i);

        generator.writer.write(typeToString(param.type, paramName));

        if (!cast(FunctionPointerType)param.type)
            generator.writer.writef(" %s", paramName);

        if (i < function_.parameters.count - 1)
            generator.writer.write(", ");
    }

    generator.writer.writeln(")");
    generator.writer.writeln("{");

    generator.writer.indent();

    foreach (reg; function_.registers)
        writeRegister(generator, reg.y);

    generator.writer.writeln();

    foreach (i, block; function_.blocks)
    {
        writeBasicBlock(generator, block.y);

        if (i < function_.blocks.count - 1)
            generator.writer.writeln();
    }

    generator.writer.dedent();

    generator.writer.writeln("}");

    generator.functionNames.add(function_, name);
}

private void writeRegister(ClangCGenerator generator, Register register)
in
{
    assert(generator);
    assert(register);
}
body
{
    auto name = "reg__" ~ register.name;

    generator.writer.writei(typeToString(register.type, name));

    if (!cast(FunctionPointerType)register.type)
        generator.writer.writef(" %s", name);

    generator.writer.writeln(";");
}

private void writeBasicBlock(ClangCGenerator generator, BasicBlock block)
in
{
    assert(generator);
    assert(block);
}
body
{
    generator.writer.writeifln("block__%s:", block.name);
    generator.writer.writeln();

    generator.writer.indent();

    foreach (insn; block.stream)
        writeInstruction(generator, insn);

    generator.writer.dedent();
}
