module mci.verifier.passes.typing;

import std.conv,
       mci.core.common,
       mci.core.container,
       mci.core.analysis.utilities,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.opcodes,
       mci.core.typing.core,
       mci.core.typing.types,
       mci.verifier.base;

public final class ConstantLoadVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.instructions)
            {
                string loadCheck(string name, string type)
                {
                    return "if (instr.opCode is opLoad" ~ name ~ " && !isType!" ~ type ~ "Type(instr.targetRegister.type))" ~
                           "    error(instr, \"The target of a '\" ~ opLoad" ~ name ~ ".name ~ \"' instruction must be of type '\" ~" ~
                           "          " ~ type ~ "Type.instance.name ~ \"'.\");";
                }

                mixin(loadCheck("I8", "Int8"));
                mixin(loadCheck("UI8", "UInt8"));
                mixin(loadCheck("I16", "Int16"));
                mixin(loadCheck("UI16", "UInt16"));
                mixin(loadCheck("I32", "Int32"));
                mixin(loadCheck("UI32", "UInt32"));
                mixin(loadCheck("I64", "Int64"));
                mixin(loadCheck("UI64", "UInt64"));
                mixin(loadCheck("F32", "Float32"));
                mixin(loadCheck("F64", "Float64"));
                mixin(loadCheck("Size", "NativeUInt"));

                if (instr.opCode is opLoadNull && !isNullable(instr.targetRegister.type))
                    error(instr, "The target of a 'load.null' opcode must be a pointer, a function pointer, an array, or a vector.");

                if (instr.opCode is opLoadFunc)
                {
                    if (!isType!FunctionPointerType(instr.targetRegister.type))
                        error(instr, "The target of a 'load.func' opcode must be a function pointer.");

                    auto func = *instr.operand.peek!Function();
                    auto target = cast(FunctionPointerType)instr.targetRegister.type;

                    if (getCallingConvention(func) != target.callingConvention)
                        error(instr, "The calling convention of the target function does not match that of the operand.");

                    if (func.returnType !is target.returnType)
                        error(instr, "The return type of the target function signature ('%s') does not match that of the operand ('%s').",
                              target.returnType ? to!string(target.returnType) : "void",
                              func.returnType ? to!string(func.returnType) : "void");

                    if (func.parameters.count != target.parameterTypes.count)
                        error(instr, "The parameter count of the target function signature ('%s') does not match that of the " ~
                              "operand ('%s').", func.parameters.count, target.parameterTypes.count);

                    for (size_t i = 0; i < func.parameters.count; i++)
                        if (func.parameters[i].type !is target.parameterTypes[i])
                            error(instr, "Parameter at index '%s' (type '%s') of the target function signature does not match " ~
                                  "that of the operand ('%s').", i, target.parameterTypes[i], func.parameters[i].type);
                }
            }
        }
    }
}

private bool areSameType(Register[] registers ...)
in
{
    assert(registers);
}
body
{
    auto noNullTypes = map(filter(toIterable(registers), (Register r) { return !!r; }), (Register r) { return r.type; });

    foreach (type; noNullTypes)
        foreach (type2; noNullTypes)
            if (type !is type2)
                return false;

    return true;
}

public final class ArithmeticVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.instructions)
            {
                if (isArithmetic(instr.opCode) || instr.opCode is opNot)
                {
                    if (!isValidInArithmetic(instr.targetRegister.type))
                        error(instr, "Target register must be a primitive, a pointer, or a vector of a primitive or a pointer.");

                    if ((instr.opCode.registers >= 1 && !isValidInArithmetic(instr.sourceRegister1.type)) ||
                        (instr.opCode.registers >= 2 && !isValidInArithmetic(instr.sourceRegister2.type)))
                        error(instr, "Source register must be a primitive, a pointer, or a vector of a primitive or a pointer.");

                    if (!areSameType(instr.targetRegister, instr.sourceRegister1, instr.sourceRegister2))
                        error(instr, "All registers must be the exact same type.");
                }
            }
        }
    }
}

public final class BitwiseVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.instructions)
            {
                if (isBitwise(instr.opCode))
                {
                    if (!isValidInBitwise(instr.targetRegister.type))
                        error(instr, "Target register must be a primitive, a pointer, or a vector of a primitive or a pointer.");

                    if ((instr.opCode.registers >= 1 && !isValidInBitwise(instr.sourceRegister1.type)) ||
                        (instr.opCode.registers >= 2 && !isValidInBitwise(instr.sourceRegister2.type)))
                        error(instr, "Source register must be a primitive, a pointer, or a vector of a primitive or a pointer.");

                    if (!areSameType(instr.targetRegister, instr.sourceRegister1, instr.sourceRegister2))
                        error(instr, "All registers must be the exact same type.");
                }
            }
        }
    }
}

public final class ShiftVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.instructions)
            {
                if (isShift(instr.opCode))
                {
                    if (!isValidInBitwise(instr.targetRegister.type))
                        error(instr, "Target register must be a primitive, a pointer, or a vector of a primitive or a pointer.");

                    if (!isValidInBitwise(instr.sourceRegister1.type))
                        error(instr, "The first source register must be a primitive, a pointer, or a vector of a primitive or a pointer.");

                    if (!isValidShiftAmountType(instr.sourceRegister2.type))
                        error(instr, "The second source register must be of type 'uint'.");
                }
            }
        }
    }
}

public final class ComparisonVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.instructions)
            {
                if (isComparison(instr.opCode))
                {
                    if (!isType!NativeUIntType(instr.targetRegister.type))
                        error(instr, "Target register must be a primitive, a pointer, or a vector of a primitive or a pointer.");

                    if (!isValidInArithmetic(instr.sourceRegister1.type) || !isValidInArithmetic(instr.sourceRegister2.type))
                        error(instr, "Source register must be a primitive, a pointer, or a vector of a primitive or a pointer.");
                }
            }
        }
    }
}

public final class ReturnTypeVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            auto instr = getFirstInstruction(bb.y, opReturn);

            if (instr.sourceRegister1.type !is function_.returnType)
                error(instr, "The type of the source register ('%s') does not match the return type of the function ('%s').",
                      instr.sourceRegister1.type, function_.returnType ? to!string(function_.returnType) : "void");
        }
    }
}
