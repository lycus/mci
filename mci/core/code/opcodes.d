module mci.core.code.opcodes;

import mci.core.container,
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
    field,
    function_,
    label,
    selector,
}

public TypeInfo operandToTypeInfo(OperandType operandType)
out (result)
{
    assert(result);
}
body
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
        case OperandType.field:
            return typeid(Field);
        case OperandType.function_:
            return typeid(Function);
        case OperandType.label:
            return typeid(BasicBlock);
        case OperandType.selector:
            return typeid(Countable!Register);
    }
}

public final class OpCode
{
    private string _name;
    private OperationCode _code;
    private OpCodeType _type;
    private OperandType _operandType;
    private uint _registers;
    private bool _hasTarget;

    invariant()
    {
        assert(_name);
        assert(_registers <= maxSourceRegisters);
    }

    private this(string name, OperationCode code, OpCodeType type, OperandType operandType,
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

    @property public string name()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public OperationCode code()
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
    out (result)
    {
        assert(result <= maxSourceRegisters);
    }
    body
    {
        return _registers;
    }

    @property public bool hasTarget()
    {
        return _hasTarget;
    }

    public override string toString()
    {
        return _name;
    }
}

public enum OperationCode : ubyte
{
    nop,
    comment,
    dead,
    raw,
    loadI8,
    loadUI8,
    loadI16,
    loadUI16,
    loadI32,
    loadUI32,
    loadI64,
    loadUI64,
    loadF32,
    loadF64,
    loadFunc,
    loadNull,
    loadSize,
    ariAdd,
    ariSub,
    ariMul,
    ariDiv,
    ariRem,
    ariNeg,
    bitAnd,
    bitOr,
    bitXOr,
    bitNeg,
    not,
    shL,
    shR,
    conv,
    memAlloc,
    memNew,
    memFree,
    memGCAlloc,
    memGCNew,
    memGCFree,
    memGet,
    memSet,
    memAddr,
    arrayGet,
    arraySet,
    arrayAddr,
    fieldGet,
    fieldSet,
    fieldAddr,
    fieldGGet,
    fieldGSet,
    fieldGAddr,
    cmpEq,
    cmpNEq,
    cmpGT,
    cmpLT,
    cmpGTEq,
    cmpLTEq,
    argPush,
    argPop,
    invoke,
    invokeTail,
    invokeIndirect,
    call,
    callTail,
    callIndirect,
    jump,
    jumpTrue,
    jumpFalse,
    leave,
    return_,
    phi,
    exThrow,
    exTry,
    exHandle,
    exEnd,
}

public OpCode opNop;
public OpCode opComment;
public OpCode opDead;
public OpCode opRaw;
public OpCode opLoadI8;
public OpCode opLoadUI8;
public OpCode opLoadI16;
public OpCode opLoadUI16;
public OpCode opLoadI32;
public OpCode opLoadUI32;
public OpCode opLoadI64;
public OpCode opLoadUI64;
public OpCode opLoadF32;
public OpCode opLoadF64;
public OpCode opLoadFunc;
public OpCode opLoadNull;
public OpCode opLoadSize;
public OpCode opAriAdd;
public OpCode opAriSub;
public OpCode opAriMul;
public OpCode opAriDiv;
public OpCode opAriRem;
public OpCode opAriNeg;
public OpCode opBitAnd;
public OpCode opBitOr;
public OpCode opBitXOr;
public OpCode opBitNeg;
public OpCode opNot;
public OpCode opShL;
public OpCode opShR;
public OpCode opConv;
public OpCode opMemAlloc;
public OpCode opMemNew;
public OpCode opMemFree;
public OpCode opMemGCAlloc;
public OpCode opMemGCNew;
public OpCode opMemGCFree;
public OpCode opMemGet;
public OpCode opMemSet;
public OpCode opMemAddr;
public OpCode opArrayGet;
public OpCode opArraySet;
public OpCode opArrayAddr;
public OpCode opFieldGet;
public OpCode opFieldSet;
public OpCode opFieldAddr;
public OpCode opFieldGGet;
public OpCode opFieldGSet;
public OpCode opFieldGAddr;
public OpCode opCmpEq;
public OpCode opCmpNEq;
public OpCode opCmpGT;
public OpCode opCmpLT;
public OpCode opCmpGTEq;
public OpCode opCmpLTEq;
public OpCode opArgPush;
public OpCode opArgPop;
public OpCode opInvoke;
public OpCode opInvokeTail;
public OpCode opInvokeIndirect;
public OpCode opCall;
public OpCode opCallTail;
public OpCode opCallIndirect;
public OpCode opJump;
public OpCode opJumpTrue;
public OpCode opJumpFalse;
public OpCode opLeave;
public OpCode opReturn;
public OpCode opPhi;
public OpCode opExThrow;
public OpCode opExTry;
public OpCode opExHandle;
public OpCode opExEnd;

public Countable!OpCode allOpCodes;

static this()
{
    auto opCodes = new List!OpCode();

    OpCode create(string name, OperationCode code, OpCodeType type, OperandType operandType, uint registers, bool hasTarget)
    in
    {
        assert(name);
        assert(registers <= maxSourceRegisters);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto op = new OpCode(name, code, type, operandType, registers, hasTarget);
        opCodes.add(op);

        return op;
    }

    opNop = create("nop", OperationCode.nop, OpCodeType.noOperation, OperandType.none, 0, false);
    opComment = create("comment", OperationCode.comment, OpCodeType.annotation, OperandType.bytes, 0, false);
    opDead = create("dead", OperationCode.dead, OpCodeType.annotation, OperandType.none, 0, false);
    opRaw = create("raw", OperationCode.raw, OpCodeType.normal, OperandType.bytes, 0, false);
    opLoadI8 = create("load.i8", OperationCode.loadI8, OpCodeType.normal, OperandType.int8, 0, true);
    opLoadUI8 = create("load.ui8", OperationCode.loadUI8, OpCodeType.normal, OperandType.uint8, 0, true);
    opLoadI16 = create("load.i16", OperationCode.loadI16, OpCodeType.normal, OperandType.int16, 0, true);
    opLoadUI16 = create("load.ui16", OperationCode.loadUI16, OpCodeType.normal, OperandType.uint16, 0, true);
    opLoadI32 = create("load.i32", OperationCode.loadI32, OpCodeType.normal, OperandType.int32, 0, true);
    opLoadUI32 = create("load.ui32", OperationCode.loadUI32, OpCodeType.normal, OperandType.uint32, 0, true);
    opLoadI64 = create("load.i64", OperationCode.loadI64, OpCodeType.normal, OperandType.int64, 0, true);
    opLoadUI64 = create("load.ui64", OperationCode.loadUI64, OpCodeType.normal, OperandType.uint64, 0, true);
    opLoadF32 = create("load.f32", OperationCode.loadF32, OpCodeType.normal, OperandType.float32, 0, true);
    opLoadF64 = create("load.f64", OperationCode.loadF64, OpCodeType.normal, OperandType.float64, 0, true);
    opLoadFunc = create("load.func", OperationCode.loadFunc, OpCodeType.normal, OperandType.function_, 0, true);
    opLoadNull = create("load.null", OperationCode.loadNull, OpCodeType.normal, OperandType.none, 0, true);
    opLoadSize = create("load.size", OperationCode.loadSize, OpCodeType.normal, OperandType.type, 0, true);
    opAriAdd = create("ari.add", OperationCode.ariAdd, OpCodeType.normal, OperandType.none, 2, true);
    opAriSub = create("ari.sub", OperationCode.ariSub, OpCodeType.normal, OperandType.none, 2, true);
    opAriMul = create("ari.mul", OperationCode.ariMul, OpCodeType.normal, OperandType.none, 2, true);
    opAriDiv = create("ari.div", OperationCode.ariDiv, OpCodeType.normal, OperandType.none, 2, true);
    opAriRem = create("ari.rem", OperationCode.ariRem, OpCodeType.normal, OperandType.none, 2, true);
    opAriNeg = create("ari.neg", OperationCode.ariNeg, OpCodeType.normal, OperandType.none, 1, true);
    opBitAnd = create("bit.and", OperationCode.bitAnd, OpCodeType.normal, OperandType.none, 2, true);
    opBitOr = create("bit.or", OperationCode.bitOr, OpCodeType.normal, OperandType.none, 2, true);
    opBitXOr = create("bit.xor", OperationCode.bitXOr, OpCodeType.normal, OperandType.none, 2, true);
    opBitNeg = create("bit.neg", OperationCode.bitNeg, OpCodeType.normal, OperandType.none, 1, true);
    opNot = create("not", OperationCode.not, OpCodeType.normal, OperandType.none, 1, true);
    opShL = create("shl", OperationCode.shL, OpCodeType.normal, OperandType.none, 2, true);
    opShR = create("shr", OperationCode.shR, OpCodeType.normal, OperandType.none, 2, true);
    opConv = create("conv", OperationCode.conv, OpCodeType.normal, OperandType.none, 1, true);
    opMemAlloc = create("mem.alloc", OperationCode.memAlloc, OpCodeType.normal, OperandType.none, 1, true);
    opMemNew = create("mem.new", OperationCode.memNew, OpCodeType.normal, OperandType.none, 0, true);
    opMemFree = create("mem.free", OperationCode.memFree, OpCodeType.normal, OperandType.none, 1, false);
    opMemGCAlloc = create("mem.gcalloc", OperationCode.memGCAlloc, OpCodeType.normal, OperandType.none, 1, true);
    opMemGCNew = create("mem.gcnew", OperationCode.memGCNew, OpCodeType.normal, OperandType.none, 0, true);
    opMemGCFree = create("mem.gcfree", OperationCode.memGCFree, OpCodeType.normal, OperandType.none, 1, false);
    opMemGet = create("mem.get", OperationCode.memGet, OpCodeType.normal, OperandType.none, 1, true);
    opMemSet = create("mem.set", OperationCode.memSet, OpCodeType.normal, OperandType.none, 2, false);
    opMemAddr = create("mem.addr", OperationCode.memAddr, OpCodeType.normal, OperandType.none, 1, true);
    opArrayGet = create("array.get", OperationCode.arrayGet, OpCodeType.normal, OperandType.none, 2, true);
    opArraySet = create("array.set", OperationCode.arraySet, OpCodeType.normal, OperandType.none, 3, false);
    opArrayAddr = create("array.addr", OperationCode.arrayAddr, OpCodeType.normal, OperandType.none, 2, true);
    opFieldGet = create("field.get", OperationCode.fieldGet, OpCodeType.normal, OperandType.field, 1, true);
    opFieldSet = create("field.set", OperationCode.fieldSet, OpCodeType.normal, OperandType.field, 2, false);
    opFieldAddr = create("field.addr", OperationCode.fieldAddr, OpCodeType.normal, OperandType.field, 1, true);
    opFieldGGet = create("field.gget", OperationCode.fieldGGet, OpCodeType.normal, OperandType.field, 0, true);
    opFieldGSet = create("field.gset", OperationCode.fieldGSet, OpCodeType.normal, OperandType.field, 1, false);
    opFieldGAddr = create("field.gaddr", OperationCode.fieldGAddr, OpCodeType.normal, OperandType.field, 0, true);
    opCmpEq = create("cmp.eq", OperationCode.cmpEq, OpCodeType.normal, OperandType.none, 2, true);
    opCmpNEq = create("cmp.neq", OperationCode.cmpNEq, OpCodeType.normal, OperandType.none, 2, true);
    opCmpGT = create("cmp.gt", OperationCode.cmpGT, OpCodeType.normal, OperandType.none, 2, true);
    opCmpLT = create("cmp.lt", OperationCode.cmpLT, OpCodeType.normal, OperandType.none, 2, true);
    opCmpGTEq = create("cmp.gteq", OperationCode.cmpGTEq, OpCodeType.normal, OperandType.none, 2, true);
    opCmpLTEq = create("cmp.lteq", OperationCode.cmpLTEq, OpCodeType.normal, OperandType.none, 2, true);
    opArgPush = create("arg.push", OperationCode.argPush, OpCodeType.normal, OperandType.none, 1, false);
    opArgPop = create("arg.pop", OperationCode.argPop, OpCodeType.normal, OperandType.none, 0, true);
    opCall = create("call", OperationCode.call, OpCodeType.controlFlow, OperandType.function_, 0, true);
    opCallTail = create("call.tail", OperationCode.callTail, OpCodeType.controlFlow, OperandType.function_, 0, true);
    opCallIndirect = create("call.indirect", OperationCode.callIndirect, OpCodeType.controlFlow, OperandType.none, 1, true);
    opInvoke = create("invoke", OperationCode.invoke, OpCodeType.controlFlow, OperandType.function_, 0, false);
    opInvokeTail = create("invoke.tail", OperationCode.invokeTail, OpCodeType.controlFlow, OperandType.function_, 0, false);
    opInvokeIndirect = create("invoke.indirect", OperationCode.invokeIndirect, OpCodeType.controlFlow, OperandType.none, 1, false);
    opJump = create("jump", OperationCode.jump, OpCodeType.controlFlow, OperandType.label, 0, false);
    opJumpTrue = create("jump.true", OperationCode.jumpTrue, OpCodeType.controlFlow, OperandType.label, 1, false);
    opJumpFalse = create("jump.false", OperationCode.jumpFalse, OpCodeType.controlFlow, OperandType.label, 1, false);
    opLeave = create("leave", OperationCode.leave, OpCodeType.controlFlow, OperandType.none, 0, false);
    opReturn = create("return", OperationCode.return_, OpCodeType.controlFlow, OperandType.none, 1, false);
    opPhi = create("phi", OperationCode.phi, OpCodeType.normal, OperandType.selector, 0, true);
    opExThrow = create("ex.throw", OperationCode.exThrow, OpCodeType.controlFlow, OperandType.uint32, 1, false);
    opExTry = create("ex.try", OperationCode.exTry, OpCodeType.annotation, OperandType.none, 0, false);
    opExHandle = create("ex.handle", OperationCode.exHandle, OpCodeType.normal, OperandType.uint32, 0, true);
    opExEnd = create("ex.end", OperationCode.exEnd, OpCodeType.annotation, OperandType.none, 0, false);

    allOpCodes = opCodes;
}
