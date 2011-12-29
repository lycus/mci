module mci.core.code.instructions;

import std.conv,
       std.variant,
       mci.core.container,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.opcodes,
       mci.core.typing.members,
       mci.core.typing.types;

public final class Register
{
    private Function _function;
    private Type _type;
    private string _name;

    invariant()
    {
        assert(_function);
        assert(_type);
        assert(_name);
    }

    package this(Function function_, string name, Type type)
    in
    {
        assert(function_);
        assert(name);
        assert(type);
    }
    body
    {
        _function = function_;
        _name = name;
        _type = type;
    }

    @property public Function function_()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _function;
    }

    @property public Type type()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _type;
    }

    @property public string name()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    public override string toString()
    {
        return _name;
    }
}

public enum uint maxSourceRegisters = 3;

alias Algebraic!(byte,
                 ubyte,
                 short,
                 ushort,
                 int,
                 uint,
                 long,
                 ulong,
                 float,
                 double,
                 ReadOnlyIndexable!byte,
                 ReadOnlyIndexable!ubyte,
                 ReadOnlyIndexable!short,
                 ReadOnlyIndexable!ushort,
                 ReadOnlyIndexable!int,
                 ReadOnlyIndexable!uint,
                 ReadOnlyIndexable!long,
                 ReadOnlyIndexable!ulong,
                 ReadOnlyIndexable!float,
                 ReadOnlyIndexable!double,
                 BasicBlock,
                 Tuple!(BasicBlock, BasicBlock),
                 Type,
                 Field,
                 Function,
                 ReadOnlyIndexable!Register,
                 FFISignature) InstructionOperand;

public final class Instruction
{
    private OpCode _opCode;
    private InstructionOperand _operand;
    private Register _targetRegister;
    private Register _sourceRegister1;
    private Register _sourceRegister2;
    private Register _sourceRegister3;

    public this(OpCode opCode, InstructionOperand operand, Register targetRegister,
                Register sourceRegister1, Register sourceRegister2, Register sourceRegister3)
    in
    {
        assert(opCode);

        if (opCode.hasTarget)
            assert(targetRegister);

        if (opCode.registers >= 1)
            assert(sourceRegister1);

        if (opCode.registers >= 2)
            assert(sourceRegister2);

        if (opCode.registers >= 3)
            assert(sourceRegister3);

        if (opCode.operandType == OperandType.none)
            assert(!operand.hasValue);
        else
            assert(operand.type == operandToTypeInfo(opCode.operandType));
    }
    body
    {
        _opCode = opCode;
        _operand = operand;
        _targetRegister = targetRegister;
        _sourceRegister1 = sourceRegister1;
        _sourceRegister2 = sourceRegister2;
        _sourceRegister3 = sourceRegister3;
    }

    @property public OpCode opCode()
    {
        return _opCode;
    }

    @property public InstructionOperand operand()
    {
        return _operand;
    }

    @property public Register targetRegister()
    {
        return _targetRegister;
    }

    @property public Register sourceRegister1()
    {
        return _sourceRegister1;
    }

    @property public Register sourceRegister2()
    {
        return _sourceRegister2;
    }

    @property public Register sourceRegister3()
    {
        return _sourceRegister3;
    }

    public override string toString()
    {
        string str;

        if (_targetRegister)
            str ~= _targetRegister.toString() ~ " = ";

        str ~= _opCode.toString();

        if (_sourceRegister1)
            str ~= " " ~ _sourceRegister1.toString();

        if (_sourceRegister2)
            str ~= ", " ~ _sourceRegister2.toString();

        if (_sourceRegister3)
            str ~= ", " ~ _sourceRegister3.toString();

        if (operand.hasValue)
        {
            str ~= " (";

            void writeArray(T)()
            {
                auto values = *_operand.peek!(ReadOnlyIndexable!T)();

                foreach (i, val; values)
                {
                    str ~= to!string(val);

                    if (i < values.count - 1)
                        str ~= ", ";
                }
            }

            switch (_opCode.operandType)
            {
                case OperandType.int8Array:
                    writeArray!byte();
                    break;
                case OperandType.uint8Array:
                    writeArray!ubyte();
                    break;
                case OperandType.int16Array:
                    writeArray!short();
                    break;
                case OperandType.uint16Array:
                    writeArray!ushort();
                    break;
                case OperandType.int32Array:
                    writeArray!int();
                    break;
                case OperandType.uint32Array:
                    writeArray!uint();
                    break;
                case OperandType.int64Array:
                    writeArray!long();
                    break;
                case OperandType.uint64Array:
                    writeArray!ulong();
                    break;
                case OperandType.float32Array:
                    writeArray!float();
                    break;
                case OperandType.float64Array:
                    writeArray!double();
                    break;
                case OperandType.branch:
                    auto tup = *operand.peek!(Tuple!(BasicBlock, BasicBlock))();
                    str ~= tup.x.toString() ~ ", " ~ tup.y.toString();
                    break;
                case OperandType.selector:
                    writeArray!Register();
                    break;
                default:
                    str ~= operand.toString();
            }
        }

        return str;
    }
}
