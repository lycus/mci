module mci.core.code.opcodes;

import mci.core.common,
       mci.core.container,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.typing.members,
       mci.core.typing.types;

public enum OpCodeType : ubyte
{
    normal,
    controlFlow,
    noOperation,
    annotation,
}

public enum OperandType : ubyte
{
    none,
    int8,
    uint8,
    int16,
    uint16,
    int32,
    uint32,
    int64,
    uint64,
    float32,
    float64,
    bytes,
    type,
    structure,
    field,
    function_,
    signature,
    label,
    selector,
}

public TypeInfo operandToTypeInfo(OperandType operandType)
{
    final switch (operandType)
    {
        case OperandType.none:
            return null;
        case OperandType.bytes:
            return typeid(Countable!ubyte);
        case OperandType.int8:
            return typeid(byte);
        case OperandType.uint8:
            return typeid(ubyte);
        case OperandType.int16:
            return typeid(short);
        case OperandType.uint16:
            return typeid(ushort);
        case OperandType.int32:
            return typeid(int);
        case OperandType.uint32:
            return typeid(uint);
        case OperandType.int64:
            return typeid(long);
        case OperandType.uint64:
            return typeid(ulong);
        case OperandType.float32:
            return typeid(float);
        case OperandType.float64:
            return typeid(double);
        case OperandType.type:
            return typeid(Type);
        case OperandType.structure:
            return typeid(StructureType);
        case OperandType.field:
            return typeid(Field);
        case OperandType.function_:
            return typeid(Function);
        case OperandType.signature:
            return typeid(FunctionPointerType);
        case OperandType.label:
            return typeid(BasicBlock);
        case OperandType.selector:
            return typeid(Countable!Register);
    }
}

public final class OpCode
{
    private string _name;
    private ubyte _code;
    private OpCodeType _type;
    private OperandType _operandType;
    private uint _registers;
    private bool _hasTarget;

    private this(string name, ubyte code, OpCodeType type, OperandType operandType,
                 uint registers, bool hasTarget)
    in
    {
        assert(name);
        assert(registers <= maxSourceRegisters);
    }
    body
    {
        _name = name;
        _code = code;
        _type = type;
        _operandType = operandType;
        _registers = registers;
        _hasTarget = hasTarget;
    }

    @property public istring name()
    {
        return _name;
    }

    @property public ubyte code()
    {
        return _code;
    }

    @property public OpCodeType type()
    {
        return _type;
    }

    @property public OperandType operandType()
    {
        return _operandType;
    }

    @property public uint registers()
    {
        return _registers;
    }

    @property public bool hasTarget()
    {
        return _hasTarget;
    }
}

// TODO: Add exception handling opcodes.
public __gshared OpCode opNop;
public __gshared OpCode opComment;
public __gshared OpCode opDead;
public __gshared OpCode opRaw;
public __gshared OpCode opLoadI8;
public __gshared OpCode opLoadUI8;
public __gshared OpCode opLoadI16;
public __gshared OpCode opLoadUI16;
public __gshared OpCode opLoadI32;
public __gshared OpCode opLoadUI32;
public __gshared OpCode opLoadI64;
public __gshared OpCode opLoadUI64;
public __gshared OpCode opLoadF32;
public __gshared OpCode opLoadF64;
public __gshared OpCode opLoadFunc;
public __gshared OpCode opLoadNull;
public __gshared OpCode opLoadSize;
public __gshared OpCode opAdd;
public __gshared OpCode opSub;
public __gshared OpCode opMul;
public __gshared OpCode opDiv;
public __gshared OpCode opRem;
public __gshared OpCode opNeg;
public __gshared OpCode opAnd;
public __gshared OpCode opOr;
public __gshared OpCode opXOr;
public __gshared OpCode opNot;
public __gshared OpCode opShL;
public __gshared OpCode opShR;
public __gshared OpCode opConv;
public __gshared OpCode opConvI8;
public __gshared OpCode opConvUI8;
public __gshared OpCode opConvI16;
public __gshared OpCode opConvUI16;
public __gshared OpCode opConvI32;
public __gshared OpCode opConvUI32;
public __gshared OpCode opConvI64;
public __gshared OpCode opConvUI64;
public __gshared OpCode opConvIN;
public __gshared OpCode opConvUIN;
public __gshared OpCode opConvF32;
public __gshared OpCode opConvF64;
public __gshared OpCode opConvFN;
public __gshared OpCode opMemAlloc;
public __gshared OpCode opMemNew;
public __gshared OpCode opMemFree;
public __gshared OpCode opMemDelete;
public __gshared OpCode opMemGet;
public __gshared OpCode opMemSet;
public __gshared OpCode opMemAddr;
public __gshared OpCode opFieldGet;
public __gshared OpCode opFieldSet;
public __gshared OpCode opFieldAddr;
public __gshared OpCode opFieldGGet;
public __gshared OpCode opFieldGSet;
public __gshared OpCode opFieldGAddr;
public __gshared OpCode opCmpEq;
public __gshared OpCode opCmpGt;
public __gshared OpCode opCmpLt;
public __gshared OpCode opCmpGtEq;
public __gshared OpCode opCmpLtEq;
public __gshared OpCode opArgPush;
public __gshared OpCode opArgPop;
public __gshared OpCode opResult;
public __gshared OpCode opCall;
public __gshared OpCode opCallTail;
public __gshared OpCode opJump;
public __gshared OpCode opJumpTrue;
public __gshared OpCode opJumpFalse;
public __gshared OpCode opLeave;
public __gshared OpCode opReturn;
public __gshared OpCode opPhi;

public __gshared Countable!OpCode allOpCodes;

static this()
{
    ubyte valueCount;
    auto opCodes = new List!OpCode();

    OpCode create(string name, OpCodeType type, OperandType operandType,
                  uint registers, bool hasTarget)
    {
        auto op = new OpCode(name, valueCount++, type, operandType,
                             registers, hasTarget);

        opCodes.add(op);
        return op;
    }

    opNop = create("nop", OpCodeType.noOperation, OperandType.none, 0, false);
    opComment = create("comment", OpCodeType.annotation, OperandType.bytes, 0, false);
    opDead = create("dead", OpCodeType.annotation, OperandType.none, 0, false);
    opRaw = create("raw", OpCodeType.normal, OperandType.bytes, 0, false);
    opLoadI8 = create("load.i8", OpCodeType.normal, OperandType.int8, 0, true);
    opLoadUI8 = create("load.ui8", OpCodeType.normal, OperandType.uint8, 0, true);
    opLoadI16 = create("load.i16", OpCodeType.normal, OperandType.int16, 0, true);
    opLoadUI16 = create("load.ui16", OpCodeType.normal, OperandType.uint16, 0, true);
    opLoadI32 = create("load.i32", OpCodeType.normal, OperandType.int32, 0, true);
    opLoadUI32 = create("load.ui32", OpCodeType.normal, OperandType.uint32, 0, true);
    opLoadI64 = create("load.i64", OpCodeType.normal, OperandType.int64, 0, true);
    opLoadUI64 = create("load.ui64", OpCodeType.normal, OperandType.uint64, 0, true);
    opLoadF32 = create("load.f32", OpCodeType.normal, OperandType.float32, 0, true);
    opLoadF64 = create("load.f64", OpCodeType.normal, OperandType.float64, 0, true);
    opLoadFunc = create("load.func", OpCodeType.normal, OperandType.function_, 0, true);
    opLoadNull = create("load.null", OpCodeType.normal, OperandType.none, 0, true);
    opLoadSize = create("load.size", OpCodeType.normal, OperandType.type, 0, true);
    opAdd = create("add", OpCodeType.normal, OperandType.none, 2, true);
    opSub = create("sub", OpCodeType.normal, OperandType.none, 2, true);
    opMul = create("mul", OpCodeType.normal, OperandType.none, 2, true);
    opDiv = create("div", OpCodeType.normal, OperandType.none, 2, true);
    opRem = create("rem", OpCodeType.normal, OperandType.none, 2, true);
    opNeg = create("neg", OpCodeType.normal, OperandType.none, 1, true);
    opAnd = create("and", OpCodeType.normal, OperandType.none, 2, true);
    opOr = create("or", OpCodeType.normal, OperandType.none, 2, true);
    opXOr = create("xor", OpCodeType.normal, OperandType.none, 2, true);
    opNot = create("not", OpCodeType.normal, OperandType.none, 1, true);
    opShL = create("shl", OpCodeType.normal, OperandType.none, 2, true);
    opShR = create("shr", OpCodeType.normal, OperandType.none, 2, true);
    opConv = create("conv", OpCodeType.normal, OperandType.type, 1, true);
    opConvI8 = create("conv.i8", OpCodeType.normal, OperandType.none, 1, true);
    opConvUI8 = create("conv.ui8", OpCodeType.normal, OperandType.none, 1, true);
    opConvI16 = create("conv.i16", OpCodeType.normal, OperandType.none, 1, true);
    opConvUI16 = create("conv.ui16", OpCodeType.normal, OperandType.none, 1, true);
    opConvI32 = create("conv.i32", OpCodeType.normal, OperandType.none, 1, true);
    opConvUI32 = create("conv.ui32", OpCodeType.normal, OperandType.none, 1, true);
    opConvI64 = create("conv.i64", OpCodeType.normal, OperandType.none, 1, true);
    opConvUI64 = create("conv.ui64", OpCodeType.normal, OperandType.none, 1, true);
    opConvIN = create("conv.in", OpCodeType.normal, OperandType.none, 1, true);
    opConvUIN = create("conv.uin", OpCodeType.normal, OperandType.none, 1, true);
    opConvF32 = create("conv.f32", OpCodeType.normal, OperandType.none, 1, true);
    opConvF64 = create("conv.f64", OpCodeType.normal, OperandType.none, 1, true);
    opConvFN = create("conv.fn", OpCodeType.normal, OperandType.none, 1, true);
    opMemAlloc = create("mem.alloc", OpCodeType.normal, OperandType.none, 1, true);
    opMemNew = create("mem.new", OpCodeType.normal, OperandType.structure, 0, true);
    opMemFree = create("mem.free", OpCodeType.normal, OperandType.none, 1, false);
    opMemDelete = create("mem.delete", OpCodeType.normal, OperandType.none, 1, false);
    opMemGet = create("mem.get", OpCodeType.normal, OperandType.none, 1, true);
    opMemSet = create("mem.set", OpCodeType.normal, OperandType.none, 2, false);
    opMemAddr = create("mem.addr", OpCodeType.normal, OperandType.none, 1, true);
    opFieldGet = create("field.get", OpCodeType.normal, OperandType.field, 1, true);
    opFieldSet = create("field.set", OpCodeType.normal, OperandType.field, 2, false);
    opFieldAddr = create("field.addr", OpCodeType.normal, OperandType.field, 1, true);
    opFieldGGet = create("field.gget", OpCodeType.normal, OperandType.field, 0, true);
    opFieldGSet = create("field.gset", OpCodeType.normal, OperandType.field, 1, false);
    opFieldGAddr = create("field.gaddr", OpCodeType.normal, OperandType.field, 0, true);
    opCmpEq = create("cmp.eq", OpCodeType.normal, OperandType.none, 2, true);
    opCmpGt = create("cmp.gt", OpCodeType.normal, OperandType.none, 2, true);
    opCmpLt = create("cmp.lt", OpCodeType.normal, OperandType.none, 2, true);
    opCmpGtEq = create("cmp.gteq", OpCodeType.normal, OperandType.none, 2, true);
    opCmpLtEq = create("cmp.lteq", OpCodeType.normal, OperandType.none, 2, true);
    opArgPush = create("arg.push", OpCodeType.normal, OperandType.none, 1, false);
    opArgPop = create("arg.pop", OpCodeType.normal, OperandType.none, 0, true);
    opCall = create("call", OpCodeType.controlFlow, OperandType.function_, 0, true);
    opCallTail = create("call.tail", OpCodeType.controlFlow, OperandType.function_, 0, true);
    opCallTail = create("call.indirect", OpCodeType.controlFlow, OperandType.signature, 0, true);
    opJump = create("jump", OpCodeType.controlFlow, OperandType.label, 0, false);
    opJumpTrue = create("jump.true", OpCodeType.controlFlow, OperandType.label, 1, false);
    opJumpFalse = create("jump.false", OpCodeType.controlFlow, OperandType.label, 1, false);
    opLeave = create("leave", OpCodeType.controlFlow, OperandType.none, 0, false);
    opReturn = create("return", OpCodeType.controlFlow, OperandType.none, 1, false);
    opPhi = create("phi", OpCodeType.normal, OperandType.selector, 0, true);

    allOpCodes = opCodes;
}
