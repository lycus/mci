module mci.core.code.instructions;

import std.variant,
       mci.core.container,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.opcodes,
       mci.core.typing.members,
       mci.core.typing.types;

public final class Register
{
    private Type _type;
    private string _name;

    invariant()
    {
        assert(_type);
        assert(_name);
    }

    package this(string name, Type type)
    in
    {
        assert(name);
        assert(type);
    }
    body
    {
        _name = name;
        _type = type;
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
}

public enum uint maxSourceRegisters = 2;

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
                 Countable!ubyte,
                 BasicBlock,
                 Type,
                 StructureType,
                 Field,
                 Function,
                 FunctionPointerType,
                 Countable!Register) InstructionOperand;

public final class Instruction
{
    private OpCode _opCode;
    private InstructionOperand _operand;
    private Register _targetRegister;
    private Register _sourceRegister1;
    private Register _sourceRegister2;

    public this(OpCode opCode, InstructionOperand operand, Register targetRegister,
                Register sourceRegister1, Register sourceRegister2)
    in
    {
        assert(opCode);

        if (opCode.hasTarget)
            assert(targetRegister !is null);

        if (opCode.registers >= 1)
            assert(sourceRegister1 !is null);

        if (opCode.registers >= 2)
            assert(sourceRegister2 !is null);

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
}
