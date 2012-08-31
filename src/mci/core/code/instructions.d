module mci.core.code.instructions;

import std.conv,
       std.variant,
       mci.core.container,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.metadata,
       mci.core.code.opcodes,
       mci.core.typing.members,
       mci.core.typing.types,
       mci.core.utilities;

public final class Register
{
    private Function _function;
    private Type _type;
    private string _name;
    private Object _uses; // Work around linker error.
    private Object _definitions;
    private Object _metadata;

    pure nothrow invariant()
    {
        assert(_function);
        assert(_type);
        assert(_name);
        assert(_uses);
        assert(_definitions);
        assert(_metadata);
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
        _uses = new NoNullList!Instruction();
        _definitions = new NoNullList!Instruction();
        _metadata = new List!MetadataPair();
    }

    @property public Function function_() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _function;
    }

    @property public Type type() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _type;
    }

    @property public string name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public ReadOnlyIndexable!Instruction uses() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return cast(ReadOnlyIndexable!Instruction)_uses;
    }

    @property public ReadOnlyIndexable!Instruction definitions() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return cast(ReadOnlyIndexable!Instruction)_definitions;
    }

    @property public List!MetadataPair metadata() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return cast(List!MetadataPair)_metadata;
    }

    public override string toString()
    {
        return escapeIdentifier(_name);
    }
}

public enum uint maxSourceRegisters = 3;

public alias Algebraic!(byte,
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
    private BasicBlock _block;
    private OpCode _opCode;
    private InstructionOperand _operand;
    private Register _targetRegister;
    private Register _sourceRegister1;
    private Register _sourceRegister2;
    private Register _sourceRegister3;
    private NoNullList!Register _registers;
    private NoNullList!Register _sourceRegisters;
    private List!MetadataPair _metadata;

    invariant()
    {
        assert(_block);
        assert(_opCode);
        assert((cast()_opCode).hasTarget ? !!_targetRegister : !_targetRegister);
        assert((cast()_opCode).registers >= 1 ? !!_sourceRegister1 : !_sourceRegister1);
        assert((cast()_opCode).registers >= 2 ? !!_sourceRegister2 : !_sourceRegister2);
        assert((cast()_opCode).registers >= 3 ? !!_sourceRegister3 : !_sourceRegister3);

        if ((cast()_opCode).operandType == OperandType.none)
            assert(!_operand.hasValue);
        else
            assert(_operand.type == operandToTypeInfo((cast()_opCode).operandType));

        assert(_metadata);
    }

    package this(BasicBlock block, OpCode opCode, InstructionOperand operand, Register targetRegister,
                 Register sourceRegister1, Register sourceRegister2, Register sourceRegister3)
    in
    {
        assert(block);
        assert(opCode);
        assert(opCode.hasTarget ? !!targetRegister : !targetRegister);
        assert(opCode.registers >= 1 ? !!sourceRegister1 : !sourceRegister1);
        assert(opCode.registers >= 2 ? !!sourceRegister2 : !sourceRegister2);
        assert(opCode.registers >= 3 ? !!sourceRegister3 : !sourceRegister3);

        if (opCode.operandType == OperandType.none)
            assert(!operand.hasValue);
        else
            assert(operand.type == operandToTypeInfo(opCode.operandType));
    }
    body
    {
        _block = block;
        _opCode = opCode;
        _operand = operand;
        _targetRegister = targetRegister;
        _sourceRegister1 = sourceRegister1;
        _sourceRegister2 = sourceRegister2;
        _sourceRegister3 = sourceRegister3;
        _metadata = new typeof(_metadata)();
    }

    @property public BasicBlock block() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _block;
    }

    @property public OpCode opCode() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _opCode;
    }

    @property public InstructionOperand operand()
    out (result)
    {
        if (_opCode.operandType == OperandType.none)
            assert(!result.hasValue);
        else
            assert(result.type == operandToTypeInfo(_opCode.operandType));
    }
    body
    {
        return _operand;
    }

    @property public Register targetRegister() pure nothrow
    out (result)
    {
        assert(_opCode.hasTarget ? !!result : !result);
    }
    body
    {
        return _targetRegister;
    }

    @property public Register sourceRegister1() pure nothrow
    out (result)
    {
        assert((cast()_opCode).registers >= 1 ? !!result : !result);
    }
    body
    {
        return _sourceRegister1;
    }

    @property public Register sourceRegister2() pure nothrow
    out (result)
    {
        assert((cast()_opCode).registers >= 2 ? !!result : !result);
    }
    body
    {
        return _sourceRegister2;
    }

    @property public Register sourceRegister3() pure nothrow
    out (result)
    {
        assert((cast()_opCode).registers >= 3 ? !!result : !result);
    }
    body
    {
        return _sourceRegister3;
    }

    @property public ReadOnlyIndexable!Register registers()
    out (result)
    {
        assert(result);
        assert((cast()result).count == (_opCode.hasTarget ? 1 : 0) + _opCode.registers);
    }
    body
    {
        if (_registers)
            return _registers;

        return _registers = toNoNullList(filter(toIterable(_targetRegister, _sourceRegister1, _sourceRegister2, _sourceRegister3),
                                         (Register r) => !!r));
    }

    @property public ReadOnlyIndexable!Register sourceRegisters()
    out (result)
    {
        assert(result);
        assert((cast()result).count == _opCode.registers);
    }
    body
    {
        if (_sourceRegisters)
            return _sourceRegisters;

        return _sourceRegisters = toNoNullList(filter(toIterable(_sourceRegister1, _sourceRegister2, _sourceRegister3), (Register r) => !!r));
    }

    @property public List!MetadataPair metadata() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _metadata;
    }

    public override string toString()
    {
        string str;

        if (_targetRegister)
            str ~= _targetRegister.toString() ~ " = ";

        str ~= _opCode.toString();

        if (!sourceRegisters.empty)
            str ~= " ";

        foreach (i, reg; sourceRegisters)
        {
            str ~= reg.toString();

            if (i != sourceRegisters.count - 1)
                str ~= ", ";
        }

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

            str ~= ")";
        }

        return str;
    }
}
