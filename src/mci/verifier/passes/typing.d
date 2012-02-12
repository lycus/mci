module mci.verifier.passes.typing;

import std.conv,
       mci.core.common,
       mci.core.container,
       mci.core.analysis.utilities,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.opcodes,
       mci.core.typing.cache,
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
                    return "if (instr.opCode is opLoad" ~ name ~ " && instr.targetRegister.type !is " ~ type ~ "Type.instance)" ~
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
                mixin(loadCheck("Align", "NativeUInt"));
                mixin(loadCheck("Offset", "NativeUInt"));

                string loadArrayCheck(string name, string type, string langType)
                {
                    return "if (instr.opCode is opLoad" ~ name ~ "A)" ~
                           "{" ~
                           "    if (!isContainerOf(instr.targetRegister.type, " ~ type ~ "Type.instance))" ~
                           "        error(instr, \"The target of a '\" ~ opLoad" ~ name ~ "A.name ~ \"' instruction must be a pointer \" ~" ~
                           "              \"to, or a vector/array of, '\" ~ " ~ type ~ "Type.instance.name ~ \"'.\");" ~
                           "" ~
                           "    if (auto vec = cast(VectorType)instr.targetRegister.type)" ~
                           "    {" ~
                           "        auto operandCount = (*instr.operand.peek!(ReadOnlyIndexable!" ~ langType ~ ")()).count;" ~
                           "" ~
                           "        if (vec.elements != operandCount)" ~
                           "            error(instr, \"Element count of the target register ('%s') does not match that of the \" ~" ~
                           "                  \"operand ('%s').\", vec.elements, operandCount);" ~
                           "    }" ~
                           "}";
                }

                mixin(loadArrayCheck("I8", "Int8", "byte"));
                mixin(loadArrayCheck("UI8", "UInt8", "ubyte"));
                mixin(loadArrayCheck("I16", "Int16", "short"));
                mixin(loadArrayCheck("UI16", "UInt16", "ushort"));
                mixin(loadArrayCheck("I32", "Int32", "int"));
                mixin(loadArrayCheck("UI32", "UInt32", "uint"));
                mixin(loadArrayCheck("I64", "Int64", "long"));
                mixin(loadArrayCheck("UI64", "UInt64", "ulong"));
                mixin(loadArrayCheck("F32", "Float32", "float"));
                mixin(loadArrayCheck("F64", "Float64", "double"));

                if (instr.opCode is opLoadNull && !isNullable(instr.targetRegister.type))
                    error(instr, "The target of a 'load.null' opcode must be a pointer, a function pointer, a reference, an array, or a vector.");
                else if (instr.opCode is opLoadFunc)
                {
                    if (!isType!FunctionPointerType(instr.targetRegister.type))
                        error(instr, "The target of a 'load.func' opcode must be a function pointer.");

                    auto func = *instr.operand.peek!Function();
                    auto target = cast(FunctionPointerType)instr.targetRegister.type;

                    if (func.callingConvention != target.callingConvention)
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
                    if ((instr.opCode is opAriAdd || instr.opCode is opAriSub) && isType!PointerType(instr.targetRegister.type))
                    {
                        if (instr.sourceRegister1.type !is instr.targetRegister.type)
                            error(instr, "The first source register must be of type ('%s')", instr.targetRegister.type);

                        if (instr.sourceRegister2.type !is NativeUIntType.instance)
                            error(instr, "The second source register must be of type 'uint'.");
                    }
                    else
                    {
                        if (!isValidInArithmetic(instr.targetRegister.type))
                            error(instr, "Target register must be a primitive.");

                        if (!isValidInArithmetic(instr.sourceRegister1.type) || (instr.opCode.registers >= 2 && !isValidInArithmetic(instr.sourceRegister2.type)))
                            error(instr, "Source register must be a primitive.");

                        if (!areSameType(instr.targetRegister, instr.sourceRegister1, instr.sourceRegister2))
                            error(instr, "All registers must be the exact same type.");
                    }
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
                        error(instr, "Target register must be an integer.");

                    if (!isValidInBitwise(instr.sourceRegister1.type) || (instr.opCode.registers >= 2 && !isValidInBitwise(instr.sourceRegister2.type)))
                        error(instr, "Source register must be an integer.");

                    if (!areSameType(instr.targetRegister, instr.sourceRegister1, instr.sourceRegister2))
                        error(instr, "All registers must be the exact same type.");
                }
            }
        }
    }
}

public final class BitShiftVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.instructions)
            {
                if (isBitShift(instr.opCode))
                {
                    if (!isValidInBitwise(instr.targetRegister.type))
                        error(instr, "Target register must be an integer.");

                    if (!isValidInBitwise(instr.sourceRegister1.type))
                        error(instr, "The first source register must be an integer.");

                    if (!areSameType(instr.targetRegister, instr.sourceRegister1))
                        error(instr, "Target register and first source register must be the exact same type.");

                    if (instr.sourceRegister2.type !is NativeUIntType.instance)
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
                    if (!isValidInArithmetic(instr.sourceRegister1.type) || !isValidInArithmetic(instr.sourceRegister2.type))
                        error(instr, "Source register must be a primitive, a pointer, or a vector of a primitive or a pointer.");

                    if (!areSameType(instr.sourceRegister1, instr.sourceRegister2))
                        error(instr, "Both source registers must be the exact same type.");

                    if (instr.targetRegister.type !is NativeUIntType.instance)
                        error(instr, "Target register must be of type 'uint'.");
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
            if (auto instr = getFirstInstruction(bb.y, opReturn))
                if (instr.sourceRegister1.type !is function_.returnType)
                    error(instr, "The type of the source register ('%s') does not match the return type of the function ('%s').",
                          instr.sourceRegister1.type, function_.returnType ? to!string(function_.returnType) : "void");
    }
}

public final class MemoryVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.instructions)
            {
                if (instr.opCode is opMemAlloc)
                {
                    if (instr.sourceRegister1.type !is NativeUIntType.instance)
                        error(instr, "Source register must be of type 'uint'.");

                    if (!isType!PointerType(instr.targetRegister.type) &&
                        !isType!ArrayType(instr.targetRegister.type))
                        error(instr, "Target register must be a pointer or an array.");
                }
                else if (instr.opCode is opMemNew)
                {
                    if (!isType!PointerType(instr.targetRegister.type) &&
                        !isType!ReferenceType(instr.targetRegister.type) &&
                        !isType!VectorType(instr.targetRegister.type))
                        error(instr, "Target register must be a pointer, a reference, or an array.");
                }
                else if (instr.opCode is opMemFree)
                {
                    if (!isTypeSpecification(instr.sourceRegister1.type))
                        error(instr, "Source register must be a pointer, a reference, an array, or a vector.");
                }
                else if (instr.opCode is opMemSAlloc || instr.opCode is opMemSNew)
                {
                    if (instr.opCode is opMemSAlloc && instr.sourceRegister1.type !is NativeUIntType.instance)
                        error(instr, "Source register must be of type 'uint'.");

                    if (!isType!PointerType(instr.targetRegister.type))
                        error(instr, "Target register must be a pointer.");
                }
            }
        }
    }
}

public final class MemoryAliasVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.instructions)
            {
                if (instr.opCode is opMemGet)
                {
                    if (auto ptr = cast(PointerType)instr.sourceRegister1.type)
                    {
                        if (instr.targetRegister.type !is ptr.elementType)
                            error(instr, "The target register must be the element type of the source register's pointer type.");
                    }
                    else
                        error(instr, "The source register must be a pointer.");
                }
                else if (instr.opCode is opMemSet)
                {
                    if (auto ptr = cast(PointerType)instr.sourceRegister1.type)
                    {
                        if (instr.sourceRegister2.type !is ptr.elementType)
                            error(instr, "The second source register must be the element type of the first source register's pointer type.");
                    }
                    else
                        error(instr, "The first source register must be a pointer.");
                }
                else if (instr.opCode is opMemAddr)
                {
                    if (auto ptr = cast(PointerType)instr.targetRegister.type)
                    {
                        if (ptr.elementType !is instr.sourceRegister1.type)
                            error(instr, "The target register must be a pointer to the type of the source register.");
                    }
                    else
                        error(instr, "The target register must be a pointer.");
                }
            }
        }
    }
}

public final class ArrayVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.instructions)
            {
                if (isArray(instr.opCode))
                {
                    if (!isType!ArrayType(instr.sourceRegister1.type) &&
                        !isType!VectorType(instr.sourceRegister1.type))
                        error(instr, "The first source register must be an array or a vector.");

                    if (instr.opCode !is opArrayLen && instr.sourceRegister2.type !is NativeUIntType.instance)
                        error(instr, "The second source register must be of type 'uint'.");

                    if (instr.opCode is opArrayGet && instr.targetRegister.type !is getElementType(instr.sourceRegister1.type))
                        error(instr, "The target register must be of the first source register's element type.");
                    else if (instr.opCode is opArraySet && instr.sourceRegister3.type !is getElementType(instr.sourceRegister1.type))
                        error(instr, "The third source register must be of the first source register's element type.");
                    else if (instr.opCode is opArrayAddr && instr.targetRegister.type !is getPointerType(getElementType(instr.sourceRegister1.type)))
                        error(instr, "The target register must be a pointer to the first source register's element type.");
                    else if (instr.opCode is opArrayLen && instr.targetRegister.type !is NativeUIntType.instance)
                        error(instr, "The target register must be of type 'uint'.");
                }
            }
        }
    }
}

public final class CallSiteTypeVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instrIndex, instr; bb.y.instructions)
            {
                if (!isCallSite(instr.opCode))
                    continue;

                Type returnType;
                auto argTypes = getSignature(instr, returnType);
                auto argCount = argTypes.count;

                foreach (argIndex, argType; argTypes)
                {
                    auto pushOp = bb.y.instructions[instrIndex - argCount + argIndex];

                    if (pushOp.sourceRegister1.type !is argType)
                        error(pushOp, "The source register must be of type '%s'.", argType.name);
                }
            }
        }
    }
}

public final class FunctionArgumentTypeVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        auto entry = function_.blocks[entryBlockName];

        if (!containsManagedCode(entry))
            return;

        foreach (i, param; function_.parameters)
        {
            auto popOp = entry.instructions[i];

            if (popOp.targetRegister.type !is param.type)
                error(popOp, "The target register must be of type '%s'.", param.type.name);
        }
    }
}
