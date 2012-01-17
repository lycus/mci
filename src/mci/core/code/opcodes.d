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
    int8Array,
    uint8Array,
    int16Array,
    uint16Array,
    int32Array,
    uint32Array,
    int64Array,
    uint64Array,
    float32Array,
    float64Array,
    type,
    field,
    function_,
    label,
    branch,
    selector,
    ffi,
}

public bool isArrayOperand(OperandType operandType)
{
    return operandType == OperandType.int8Array ||
           operandType == OperandType.uint8Array ||
           operandType == OperandType.int16Array ||
           operandType == OperandType.uint16Array ||
           operandType == OperandType.int32Array ||
           operandType == OperandType.uint32Array ||
           operandType == OperandType.int64Array ||
           operandType == OperandType.uint64Array ||
           operandType == OperandType.float32Array ||
           operandType == OperandType.float64Array;
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
        case OperandType.int8Array:
            return typeid(ReadOnlyIndexable!byte);
        case OperandType.uint8Array:
            return typeid(ReadOnlyIndexable!ubyte);
        case OperandType.int16Array:
            return typeid(ReadOnlyIndexable!short);
        case OperandType.uint16Array:
            return typeid(ReadOnlyIndexable!ushort);
        case OperandType.int32Array:
            return typeid(ReadOnlyIndexable!int);
        case OperandType.uint32Array:
            return typeid(ReadOnlyIndexable!uint);
        case OperandType.int64Array:
            return typeid(ReadOnlyIndexable!long);
        case OperandType.uint64Array:
            return typeid(ReadOnlyIndexable!ulong);
        case OperandType.float32Array:
            return typeid(ReadOnlyIndexable!float);
        case OperandType.float64Array:
            return typeid(ReadOnlyIndexable!double);
        case OperandType.type:
            return typeid(Type);
        case OperandType.field:
            return typeid(Field);
        case OperandType.function_:
            return typeid(Function);
        case OperandType.label:
            return typeid(BasicBlock);
        case OperandType.branch:
            return typeid(Tuple!(BasicBlock, BasicBlock));
        case OperandType.selector:
            return typeid(ReadOnlyIndexable!Register);
        case OperandType.ffi:
            return typeid(FFISignature);
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
    loadI8A,
    loadUI8A,
    loadI16A,
    loadUI16A,
    loadI32A,
    loadUI32A,
    loadI64A,
    loadUI64A,
    loadF32A,
    loadF64A,
    loadFunc,
    loadNull,
    loadSize,
    loadAlign,
    loadOffset,
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
    memSAlloc,
    memSNew,
    memPin,
    memUnpin,
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
    raw,
    ffi,
    jump,
    jumpCond,
    leave,
    return_,
    phi,
    exThrow,
    exTry,
    exHandle,
    exEnd,
}

public __gshared OpCode opNop;
public __gshared OpCode opComment;
public __gshared OpCode opDead;
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
public __gshared OpCode opLoadI8A;
public __gshared OpCode opLoadUI8A;
public __gshared OpCode opLoadI16A;
public __gshared OpCode opLoadUI16A;
public __gshared OpCode opLoadI32A;
public __gshared OpCode opLoadUI32A;
public __gshared OpCode opLoadI64A;
public __gshared OpCode opLoadUI64A;
public __gshared OpCode opLoadF32A;
public __gshared OpCode opLoadF64A;
public __gshared OpCode opLoadFunc;
public __gshared OpCode opLoadNull;
public __gshared OpCode opLoadSize;
public __gshared OpCode opLoadAlign;
public __gshared OpCode opLoadOffset;
public __gshared OpCode opAriAdd;
public __gshared OpCode opAriSub;
public __gshared OpCode opAriMul;
public __gshared OpCode opAriDiv;
public __gshared OpCode opAriRem;
public __gshared OpCode opAriNeg;
public __gshared OpCode opBitAnd;
public __gshared OpCode opBitOr;
public __gshared OpCode opBitXOr;
public __gshared OpCode opBitNeg;
public __gshared OpCode opNot;
public __gshared OpCode opShL;
public __gshared OpCode opShR;
public __gshared OpCode opConv;
public __gshared OpCode opMemAlloc;
public __gshared OpCode opMemNew;
public __gshared OpCode opMemFree;
public __gshared OpCode opMemGCAlloc;
public __gshared OpCode opMemGCNew;
public __gshared OpCode opMemGCFree;
public __gshared OpCode opMemSAlloc;
public __gshared OpCode opMemSNew;
public __gshared OpCode opMemPin;
public __gshared OpCode opMemUnpin;
public __gshared OpCode opMemGet;
public __gshared OpCode opMemSet;
public __gshared OpCode opMemAddr;
public __gshared OpCode opArrayGet;
public __gshared OpCode opArraySet;
public __gshared OpCode opArrayAddr;
public __gshared OpCode opFieldGet;
public __gshared OpCode opFieldSet;
public __gshared OpCode opFieldAddr;
public __gshared OpCode opFieldGGet;
public __gshared OpCode opFieldGSet;
public __gshared OpCode opFieldGAddr;
public __gshared OpCode opCmpEq;
public __gshared OpCode opCmpNEq;
public __gshared OpCode opCmpGT;
public __gshared OpCode opCmpLT;
public __gshared OpCode opCmpGTEq;
public __gshared OpCode opCmpLTEq;
public __gshared OpCode opArgPush;
public __gshared OpCode opArgPop;
public __gshared OpCode opInvoke;
public __gshared OpCode opInvokeTail;
public __gshared OpCode opInvokeIndirect;
public __gshared OpCode opCall;
public __gshared OpCode opCallTail;
public __gshared OpCode opCallIndirect;
public __gshared OpCode opRaw;
public __gshared OpCode opFFI;
public __gshared OpCode opJump;
public __gshared OpCode opJumpCond;
public __gshared OpCode opLeave;
public __gshared OpCode opReturn;
public __gshared OpCode opPhi;
public __gshared OpCode opExThrow;
public __gshared OpCode opExTry;
public __gshared OpCode opExHandle;
public __gshared OpCode opExEnd;

public __gshared ReadOnlyIndexable!OpCode allOpCodes;

shared static this()
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
    opComment = create("comment", OperationCode.comment, OpCodeType.annotation, OperandType.uint8Array, 0, false);
    opDead = create("dead", OperationCode.dead, OpCodeType.annotation, OperandType.none, 0, false);
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
    opLoadI8A = create("load.i8a", OperationCode.loadI8A, OpCodeType.normal, OperandType.int8Array, 0, true);
    opLoadUI8A = create("load.ui8a", OperationCode.loadUI8A, OpCodeType.normal, OperandType.uint8Array, 0, true);
    opLoadI16A = create("load.i16a", OperationCode.loadI16A, OpCodeType.normal, OperandType.int16Array, 0, true);
    opLoadUI16A = create("load.ui16a", OperationCode.loadUI16A, OpCodeType.normal, OperandType.uint16Array, 0, true);
    opLoadI32A = create("load.i32a", OperationCode.loadI32A, OpCodeType.normal, OperandType.int32Array, 0, true);
    opLoadUI32A = create("load.ui32a", OperationCode.loadUI32A, OpCodeType.normal, OperandType.uint32Array, 0, true);
    opLoadI64A = create("load.i64a", OperationCode.loadI64A, OpCodeType.normal, OperandType.int64Array, 0, true);
    opLoadUI64A = create("load.ui64a", OperationCode.loadUI64A, OpCodeType.normal, OperandType.uint64Array, 0, true);
    opLoadF32A = create("load.f32a", OperationCode.loadF32A, OpCodeType.normal, OperandType.float32Array, 0, true);
    opLoadF64A = create("load.f64a", OperationCode.loadF64A, OpCodeType.normal, OperandType.float64Array, 0, true);
    opLoadFunc = create("load.func", OperationCode.loadFunc, OpCodeType.normal, OperandType.function_, 0, true);
    opLoadNull = create("load.null", OperationCode.loadNull, OpCodeType.normal, OperandType.none, 0, true);
    opLoadSize = create("load.size", OperationCode.loadSize, OpCodeType.normal, OperandType.type, 0, true);
    opLoadAlign = create("load.align", OperationCode.loadAlign, OpCodeType.normal, OperandType.type, 0, true);
    opLoadOffset = create("load.offset", OperationCode.loadOffset, OpCodeType.normal, OperandType.field, 0, true);
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
    opMemSAlloc = create("mem.salloc", OperationCode.memSAlloc, OpCodeType.normal, OperandType.none, 1, true);
    opMemSNew = create("mem.snew", OperationCode.memSNew, OpCodeType.normal, OperandType.none, 0, true);
    opMemPin = create("mem.pin", OperationCode.memPin, OpCodeType.normal, OperandType.none, 1, true);
    opMemUnpin = create("mem.unpin", OperationCode.memUnpin, OpCodeType.normal, OperandType.none, 1, false);
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
    opCall = create("call", OperationCode.call, OpCodeType.normal, OperandType.function_, 0, true);
    opCallTail = create("call.tail", OperationCode.callTail, OpCodeType.normal, OperandType.function_, 0, true);
    opCallIndirect = create("call.indirect", OperationCode.callIndirect, OpCodeType.normal, OperandType.none, 1, true);
    opInvoke = create("invoke", OperationCode.invoke, OpCodeType.normal, OperandType.function_, 0, false);
    opInvokeTail = create("invoke.tail", OperationCode.invokeTail, OpCodeType.normal, OperandType.function_, 0, false);
    opInvokeIndirect = create("invoke.indirect", OperationCode.invokeIndirect, OpCodeType.normal, OperandType.none, 1, false);
    opRaw = create("raw", OperationCode.raw, OpCodeType.controlFlow, OperandType.uint8Array, 0, false);
    opFFI = create("ffi", OperationCode.ffi, OpCodeType.controlFlow, OperandType.ffi, 0, false);
    opJump = create("jump", OperationCode.jump, OpCodeType.controlFlow, OperandType.label, 0, false);
    opJumpCond = create("jump.cond", OperationCode.jumpCond, OpCodeType.controlFlow, OperandType.branch, 1, false);
    opLeave = create("leave", OperationCode.leave, OpCodeType.controlFlow, OperandType.none, 0, false);
    opReturn = create("return", OperationCode.return_, OpCodeType.controlFlow, OperandType.none, 1, false);
    opPhi = create("phi", OperationCode.phi, OpCodeType.normal, OperandType.selector, 0, true);
    opExThrow = create("ex.throw", OperationCode.exThrow, OpCodeType.controlFlow, OperandType.uint32, 1, false);
    opExTry = create("ex.try", OperationCode.exTry, OpCodeType.annotation, OperandType.none, 0, false);
    opExHandle = create("ex.handle", OperationCode.exHandle, OpCodeType.normal, OperandType.uint32, 0, true);
    opExEnd = create("ex.end", OperationCode.exEnd, OpCodeType.annotation, OperandType.none, 0, false);

    allOpCodes = opCodes;
}
