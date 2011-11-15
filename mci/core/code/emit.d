module mci.core.code.emit;

import mci.core.container,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.opcodes,
       mci.core.typing.members,
       mci.core.typing.types;

public class FunctionEmitter
{
    private Function _function;

    public this(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
        _function = function_;
    }

    @property public final Function function_()
    {
        return _function;
    }

    public final Register register(string name, Type type)
    in
    {
        assert(name);
        assert(type);
    }
    body
    {
        return _function.createRegister(name, type);
    }

    public final BasicBlockEmitter block(string name)
    in
    {
        assert(name);
    }
    body
    {
        return new BasicBlockEmitter(_function.createBasicBlock(name));
    }
}

public class BasicBlockEmitter
{
    private BasicBlock _block;

    public this(BasicBlock block)
    in
    {
        assert(block);
    }
    body
    {
        _block = block;
    }

    @property public final BasicBlock block()
    {
        return _block;
    }

    private mixin template DefineEmit(string OperandType)
    {
        mixin("public final BasicBlockEmitter emitTarget(OpCode opCode, " ~ OperandType ~ " operand, Register source1," ~
              "                                          Register source2, Register target)" ~
              "{" ~
              "    _block.instructions.add(new Instruction(opCode, InstructionOperand(operand), target, source1, source2));" ~
              "    return this;" ~
              "}" ~
              "" ~
              "public final BasicBlockEmitter emitTarget(OpCode opCode, " ~ OperandType ~ " operand, Register source1," ~
              "                                          Register target)" ~
              "{" ~
              "    emitTarget(opCode, operand, source1, null, target);" ~
              "    return this;" ~
              "}" ~
              "" ~
              "public final BasicBlockEmitter emitTarget(OpCode opCode, " ~ OperandType ~ " operand, Register target)" ~
              "{" ~
              "    emitTarget(opCode, operand, null, null, target);" ~
              "    return this;" ~
              "}" ~
              "" ~
              "public final BasicBlockEmitter emit(OpCode opCode, " ~ OperandType ~ " operand, Register source1," ~
              "                                    Register source2)" ~
              "{" ~
              "    emitTarget(opCode, operand, source1, source2, null);" ~
              "    return this;" ~
              "}" ~
              "" ~
              "public final BasicBlockEmitter emit(OpCode opCode, " ~ OperandType ~ " operand, Register source1)" ~
              "{" ~
              "    emitTarget(opCode, operand, source1, null, null);" ~
              "    return this;" ~
              "}" ~
              "" ~
              "public final BasicBlockEmitter emit(OpCode opCode, " ~ OperandType ~ " operand)" ~
              "{" ~
              "    emitTarget(opCode, operand, null, null, null);" ~
              "    return this;" ~
              "}");
    }

    mixin DefineEmit!"byte";
    mixin DefineEmit!"ubyte";
    mixin DefineEmit!"short";
    mixin DefineEmit!"ushort";
    mixin DefineEmit!"int";
    mixin DefineEmit!"uint";
    mixin DefineEmit!"long";
    mixin DefineEmit!"ulong";
    mixin DefineEmit!"float";
    mixin DefineEmit!"double";
    mixin DefineEmit!"Countable!ubyte";
    mixin DefineEmit!"BasicBlock";
    mixin DefineEmit!"Type";
    mixin DefineEmit!"StructureType";
    mixin DefineEmit!"Field";
    mixin DefineEmit!"Function";
    mixin DefineEmit!"FunctionPointerType";
    mixin DefineEmit!"Countable!Register";

    public final BasicBlockEmitter emitTarget(OpCode opCode, Register source1, Register source2, Register target)
    {
        _block.instructions.add(new Instruction(opCode, InstructionOperand(), source1, source2, target));
        return this;
    }

    public final BasicBlockEmitter emitTarget(OpCode opCode, Register source1, Register target)
    {
        emitTarget(opCode, source1, null, target);
        return this;
    }

    public final BasicBlockEmitter emitTarget(OpCode opCode, Register target)
    {
        emitTarget(opCode, null, null, target);
        return this;
    }

    public final BasicBlockEmitter emit(OpCode opCode, Register source1, Register source2)
    {
        emitTarget(opCode, source1, source2, null);
        return this;
    }

    public final BasicBlockEmitter emit(OpCode opCode, Register source1)
    {
        emitTarget(opCode, source1, null, null);
        return this;
    }

    public final BasicBlockEmitter emit(OpCode opCode)
    {
        emitTarget(opCode, null, null, null);
        return this;
    }
}
