module mci.verifier.passes.typing;

import std.conv,
       mci.core.common,
       mci.core.analysis.utilities,
       mci.core.code.functions,
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

                if (instr.opCode is opLoadNull && !isNullable(instr.targetRegister.type))
                    error(instr, "The target of a 'load.null' opcode must be a pointer, a function pointer, an array, or a vector.");

                if (instr.opCode is opLoadFunc)
                {
                    if (!isType!FunctionPointerType(instr.targetRegister.type))
                        error(instr, "The target of a 'load.func' opcode must be a function pointer.");

                    auto func = *instr.operand.peek!Function();
                    auto target = cast(FunctionPointerType)instr.targetRegister.type;

                    if (func.returnType !is target.returnType)
                        error(instr, "The return type of the target function signature does not match that of the operand.");

                    if (func.parameters.count != target.parameterTypes.count)
                        error(instr, "The parameter count of the target function signature does not match that of the operand.");

                    for (size_t i = 0; i < func.parameters.count; i++)
                        if (func.parameters[i].type !is target.parameterTypes[i])
                            error(instr, "Parameter at index '" ~ to!string(i) ~
                                  "' of the target function signature does not match that of the operand.");
                }
            }
        }
    }
}
