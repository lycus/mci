module mci.verifier.passes.typing;

import std.conv,
       mci.core.common,
       mci.core.container,
       mci.core.analysis.utilities,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.stream,
       mci.core.code.opcodes,
       mci.core.typing.cache,
       mci.core.typing.core,
       mci.core.typing.members,
       mci.core.typing.types,
       mci.verifier.base;

public final class ConstantLoadVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.stream)
            {
                string loadCheck(string name, string type)
                {
                    return "if (instr.opCode is opLoad" ~ name ~ " && instr.targetRegister.type !is " ~ type ~ "Type.instance)" ~
                           "    error(instr, \"The target of a '%s' instruction must be of type '%s'.\", opLoad" ~ name ~ ", " ~ type ~ "Type.instance);";
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
                           "        error(instr, \"The target of a '%s' instruction must be a pointer to, or a vector or array of, '%s'.\"," ~
                           "              opLoad" ~ name ~ "A, " ~ type ~ "Type.instance);" ~
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
                    error(instr, "The target of a 'load.null' instruction must be a pointer, a function pointer, a reference, an array, or a vector.");
                else if (instr.opCode is opLoadFunc)
                {
                    if (!isType!FunctionPointerType(instr.targetRegister.type))
                        error(instr, "The target of a 'load.func' instruction must be a function pointer.");

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
    auto noNullTypes = map(filter(toIterable(registers), (Register r) => !!r), (Register r) => r.type);

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
            foreach (instr; bb.y.stream)
            {
                if (isArithmetic(instr.opCode) || instr.opCode is opNot)
                {
                    if ((instr.opCode is opAriAdd || instr.opCode is opAriSub) && isType!PointerType(instr.targetRegister.type))
                    {
                        if (instr.sourceRegister1.type !is instr.targetRegister.type)
                            error(instr, "The first source register must be of type '%s'.", instr.targetRegister.type);

                        if (instr.sourceRegister2.type !is NativeUIntType.instance)
                            error(instr, "The second source register must be of type 'uint'.");
                    }
                    else
                    {
                        if (!isValidInArithmetic(instr.targetRegister.type))
                            error(instr, "Target register must be a primitive.");

                        if (!isValidInArithmetic(instr.sourceRegister1.type) ||
                            (instr.opCode.registers >= 2 && !isValidInArithmetic(instr.sourceRegister2.type)))
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
            foreach (instr; bb.y.stream)
            {
                if (isBitwise(instr.opCode))
                {
                    if (!isValidInBitwise(instr.targetRegister.type))
                        error(instr, "Target register must be an integer.");

                    if (!isValidInBitwise(instr.sourceRegister1.type) ||
                        (instr.opCode.registers >= 2 && !isValidInBitwise(instr.sourceRegister2.type)))
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
            foreach (instr; bb.y.stream)
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
            foreach (instr; bb.y.stream)
            {
                if (isComparison(instr.opCode))
                {
                    if (!isValidInComparison(instr.sourceRegister1.type) || !isValidInComparison(instr.sourceRegister2.type))
                        error(instr, "Source register must be a primitive or a pointer.");

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
            foreach (instr; bb.y.stream)
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

public final class MemoryPinVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.stream)
            {
                if (instr.opCode is opMemPin)
                {
                    if (instr.targetRegister.type !is NativeUIntType.instance)
                        error(instr, "Target register must be of type 'uint'.");

                    if (!isManaged(instr.sourceRegister1.type))
                        error(instr, "Source register must be a reference, an array, or a vector.");
                }
                else if (instr.opCode is opMemUnpin)
                {
                    if (instr.sourceRegister1.type !is NativeUIntType.instance)
                        error(instr, "Source register must be of type 'uint'.");
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
            foreach (instr; bb.y.stream)
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
            foreach (instr; bb.y.stream)
            {
                if (isArray(instr.opCode))
                {
                    if (!isArrayOrVector(instr.sourceRegister1.type))
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

public final class ArrayArithmeticVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.stream)
            {
                if (isArrayArithmetic(instr.opCode) || instr.opCode is opArrayNot)
                {
                    if ((instr.opCode is opArrayAriAdd || instr.opCode is opArrayAriSub) &&
                        isArrayContainerOfT!PointerType(instr.sourceRegister1.type))
                    {
                        if (!isArrayContainerOf(instr.sourceRegister2.type, getElementType(instr.sourceRegister1.type)))
                            error(instr, "The second source register must be an array or vector with the same element type as the first source register.");

                        if (!isArrayContainerOfOrElement(instr.sourceRegister3.type, NativeUIntType.instance))
                            error(instr, "The third source register must be of type 'uint' or an array or vector of these.");
                    }
                    else
                    {
                        if (!isArrayOrVector(instr.sourceRegister1.type) || !isValidInArithmetic(getElementType(instr.sourceRegister1.type)))
                            error(instr, "The first source register must be an array or vector of a primitive.");

                        if (!isArrayContainerOf(instr.sourceRegister2.type, getElementType(instr.sourceRegister1.type)))
                            error(instr, "The second source register must be an array or vector with the same element type as the first source register.");

                        if (instr.opCode.registers >= 3 &&
                            !isArrayContainerOfOrElement(instr.sourceRegister3.type, getElementType(instr.sourceRegister1.type)))
                            error(instr, "The third source register must be of the first source register's element type or an array or vector of it.");
                    }
                }
            }
        }
    }
}

public final class ArrayBitwiseVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.stream)
            {
                if (isArrayBitwise(instr.opCode))
                {
                    if (!isArrayOrVector(instr.sourceRegister1.type) || !isValidInBitwise(getElementType(instr.sourceRegister1.type)))
                        error(instr, "The first source register must be an array or vector of integers.");

                    if (!isArrayContainerOf(instr.sourceRegister2.type, getElementType(instr.sourceRegister1.type)))
                        error(instr, "The second source register must be an array or vector with the same element type as the first source register.");

                    if (instr.opCode.registers >= 3 &&
                        !isArrayContainerOfOrElement(instr.sourceRegister3.type, getElementType(instr.sourceRegister1.type)))
                        error(instr, "The third source register must be of the first source register's element type or an array or vector of it.");
                }
            }
        }
    }
}

public final class ArrayBitShiftVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.stream)
            {
                if (isArrayBitShift(instr.opCode))
                {
                    if (!isArrayOrVector(instr.sourceRegister1.type) || !isValidInBitwise(getElementType(instr.sourceRegister1.type)))
                        error(instr, "The first source register must be an array or vector of integers.");

                    if (!isArrayContainerOf(instr.sourceRegister2.type, getElementType(instr.sourceRegister1.type)))
                        error(instr, "The second source register must be an array or vector with the same element type as the first source register.");

                    if (!isArrayContainerOfOrElement(instr.sourceRegister3.type, NativeUIntType.instance))
                        error(instr, "The third source register must be of type 'uint' or an array or vector of these.");
                }
            }
        }
    }
}

public final class ArrayComparisonVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.stream)
            {
                if (isArrayComparison(instr.opCode))
                {
                    if (!isArrayContainerOf(instr.sourceRegister1.type, NativeUIntType.instance))
                        error(instr, "The first source register must be an array or vector of 'uint'.");

                    if (!isArrayOrVector(instr.sourceRegister2.type) || !isValidInBitwise(getElementType(instr.sourceRegister2.type)))
                        error(instr, "The second source register must be an array or vector of primitives or pointers.");

                    if (!isArrayContainerOfOrElement(instr.sourceRegister3.type, getElementType(instr.sourceRegister2.type)))
                        error(instr, "The third source register must be of the second source register's element type or an array or vector of it.");
                }
            }
        }
    }
}

public final class ArrayConversionVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.stream)
            {
                if (instr.opCode is opArrayConv)
                {
                    auto tgt = instr.targetRegister.type;
                    auto src = instr.sourceRegister1.type;

                    if (isType!VectorType(src) && isType!VectorType(tgt) && isConvertibleTo(getElementType(src), getElementType(tgt)))
                        continue;

                    if (isType!ArrayType(src) && isType!ArrayType(tgt) && isConvertibleTo(getElementType(src), getElementType(tgt)))
                        continue;

                    error(instr, "Invalid types in 'array.conv' operation.");
                }
            }
        }
    }
}

public final class FieldTypeVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.stream)
            {
                auto field = instr.operand.peek!Field();

                if ((instr.opCode is opFieldGet || instr.opCode is opFieldSet ||
                    instr.opCode is opFieldStaticGet || instr.opCode is opFieldStaticSet) &&
                    instr.targetRegister.type !is field.type)
                {
                    error(instr, "Target register must be the type of the field reference.");
                }
                else if ((instr.opCode is opFieldAddr || instr.opCode is opFieldStaticAddr) && instr.targetRegister.type !is getPointerType(field.type))
                    error(instr, "Target register must be a pointer to the field's type.");

                if (instr.opCode is opFieldGet || instr.opCode is opFieldSet || instr.opCode is opFieldAddr)
                {
                    if (instr.sourceRegister1.type !is field.declaringType &&
                        instr.sourceRegister1.type !is getPointerType(field.declaringType) &&
                        instr.sourceRegister1.type !is getReferenceType(field.declaringType))
                        error(instr, "The first source register must be the field's declaring type or a pointer or reference to the field's " ~
                                     "declaring type.");
                }
            }
        }
    }
}

public final class UserFieldVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.stream)
            {
                if ((instr.opCode is opFieldUserGet || instr.opCode is opFieldUserSet || instr.opCode is opFieldUserAddr) &&
                    !isManaged(instr.sourceRegister1.type))
                    error(instr, "The first source register must be a reference, an array, or a vector.");

                if (instr.opCode is opFieldUserSet && !isManaged(instr.sourceRegister2.type))
                    error(instr, "The second source register must be a reference, an array, or a vector.");
                else if (instr.opCode is opFieldUserGet && !isManaged(instr.targetRegister.type))
                    error(instr, "The target register must be a reference, an array, or a vector.");
                else if (instr.opCode is opFieldUserAddr)
                    if (!isType!PointerType(instr.targetRegister.type) || !isManaged(getElementType(instr.targetRegister.type)))
                        error(instr, "The target register must be a pointer to either a reference, an array, or a vector.");
            }
        }
    }
}

public final class ConversionVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
            foreach (instr; bb.y.stream)
                if (instr.opCode is opConv)
                    if (!isConvertibleTo(instr.sourceRegister1.type, instr.targetRegister.type))
                        error(instr, "Invalid types in 'conv' operation.");
    }
}

public final class JumpTypeVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
            foreach (instr; bb.y.stream)
                if (instr.opCode is opJumpCond && instr.sourceRegister1.type !is NativeUIntType.instance)
                    error(instr, "Source register must be of type 'uint'.");
    }
}

public final class CallSiteTypeVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instrIndex, instr; bb.y.stream)
            {
                if (!isCallSite(instr.opCode))
                    continue;

                Type returnType;
                auto argTypes = getSignature(instr, returnType);
                auto argCount = argTypes.count;

                foreach (argIndex, argType; argTypes)
                {
                    auto pushOp = bb.y.stream[instrIndex - argCount + argIndex];

                    if (pushOp.sourceRegister1.type !is argType)
                        error(pushOp, "The source register must be of type '%s'.", argType);
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
            auto popOp = entry.stream[i];

            if (popOp.targetRegister.type !is param.type)
                error(popOp, "The target register must be of type '%s'.", param.type);
        }
    }
}

public final class PhiTypeVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
            foreach (instr; bb.y.stream)
                if (instr.opCode is opPhi)
                    foreach (reg; *instr.operand.peek!(ReadOnlyIndexable!Register)())
                        if (reg.type !is instr.targetRegister.type)
                            error(instr, "The type of selector registers must match the 'phi' instruction's target register type.");
    }
}

public final class ExceptionTypeVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.stream)
            {
                if (instr.opCode is opEHThrow && !isType!ReferenceType(instr.sourceRegister1.type))
                    error(instr, "The source register must be a reference.");

                if (instr.opCode is opEHCatch && !isType!ReferenceType(instr.targetRegister.type))
                    error(instr, "The target register must be a reference.");
            }
        }
    }
}
