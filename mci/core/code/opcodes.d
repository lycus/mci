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
    structure,
    field,
    function_,
    signature,
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
    nop = 0,
    comment = 1,
    dead = 2,
    raw = 3,
    loadI8 = 4,
    loadUI8 = 5,
    loadI16 = 6,
    loadUI16 = 7,
    loadI32 = 8,
    loadUI32 = 9,
    loadI64 = 10,
    loadUI64 = 11,
    loadF32 = 12,
    loadF64 = 13,
    loadFunc = 14,
    loadNull = 15,
    loadSize = 16,
    add = 17,
    sub = 18,
    mul = 19,
    div = 20,
    rem = 21,
    neg = 22,
    and = 23,
    or = 24,
    xOr = 25,
    not = 26,
    shL = 27,
    shR = 28,
    conv = 29,
    memAlloc = 30,
    memNew = 31,
    memFree = 32,
    memDelete = 33,
    memGet = 34,
    memSet = 35,
    memAddr = 36,
    arrayGet = 37,
    arraySet = 38,
    arrayAddr = 39,
    fieldGet = 40,
    fieldSet = 41,
    fieldAddr = 42,
    fieldGGet = 43,
    fieldGSet = 44,
    fieldGAddr = 45,
    cmpEq = 46,
    cmpGT = 47,
    cmpLT = 48,
    cmpGTEq = 49,
    cmpLTEq = 50,
    argPush = 51,
    argPop = 52,
    result = 53,
    invoke = 54,
    invokeTail = 55,
    invokeIndirect = 56,
    call = 57,
    callTail = 58,
    callIndirect = 59,
    jump = 60,
    jumpTrue = 61,
    jumpFalse = 62,
    leave = 63,
    return_ = 64,
    phi = 65,
    exThrow = 66,
    exTry = 67,
    exHandle = 68,
    exEnd = 69,
}

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
public __gshared OpCode opMemAlloc;
public __gshared OpCode opMemNew;
public __gshared OpCode opMemFree;
public __gshared OpCode opMemDelete;
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
public __gshared OpCode opJump;
public __gshared OpCode opJumpTrue;
public __gshared OpCode opJumpFalse;
public __gshared OpCode opLeave;
public __gshared OpCode opReturn;
public __gshared OpCode opPhi;
public __gshared OpCode opExThrow;
public __gshared OpCode opExTry;
public __gshared OpCode opExHandle;
public __gshared OpCode opExEnd;

public __gshared Countable!OpCode allOpCodes;

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
    opAdd = create("add", OperationCode.add, OpCodeType.normal, OperandType.none, 2, true);
    opSub = create("sub", OperationCode.sub, OpCodeType.normal, OperandType.none, 2, true);
    opMul = create("mul", OperationCode.mul, OpCodeType.normal, OperandType.none, 2, true);
    opDiv = create("div", OperationCode.div, OpCodeType.normal, OperandType.none, 2, true);
    opRem = create("rem", OperationCode.rem, OpCodeType.normal, OperandType.none, 2, true);
    opNeg = create("neg", OperationCode.neg, OpCodeType.normal, OperandType.none, 1, true);
    opAnd = create("and", OperationCode.and, OpCodeType.normal, OperandType.none, 2, true);
    opOr = create("or", OperationCode.or, OpCodeType.normal, OperandType.none, 2, true);
    opXOr = create("xor", OperationCode.xOr, OpCodeType.normal, OperandType.none, 2, true);
    opNot = create("not", OperationCode.not, OpCodeType.normal, OperandType.none, 1, true);
    opShL = create("shl", OperationCode.shL, OpCodeType.normal, OperandType.none, 2, true);
    opShR = create("shr", OperationCode.shR, OpCodeType.normal, OperandType.none, 2, true);
    opConv = create("conv", OperationCode.conv, OpCodeType.normal, OperandType.type, 1, true);
    opMemAlloc = create("mem.alloc", OperationCode.memAlloc, OpCodeType.normal, OperandType.type, 1, true);
    opMemNew = create("mem.new", OperationCode.memNew, OpCodeType.normal, OperandType.structure, 0, true);
    opMemFree = create("mem.free", OperationCode.memFree, OpCodeType.normal, OperandType.none, 1, false);
    opMemDelete = create("mem.delete", OperationCode.memDelete, OpCodeType.normal, OperandType.none, 1, false);
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
    opCmpGT = create("cmp.gt", OperationCode.cmpGT, OpCodeType.normal, OperandType.none, 2, true);
    opCmpLT = create("cmp.lt", OperationCode.cmpLT, OpCodeType.normal, OperandType.none, 2, true);
    opCmpGTEq = create("cmp.gteq", OperationCode.cmpGTEq, OpCodeType.normal, OperandType.none, 2, true);
    opCmpLTEq = create("cmp.lteq", OperationCode.cmpLTEq, OpCodeType.normal, OperandType.none, 2, true);
    opArgPush = create("arg.push", OperationCode.argPush, OpCodeType.normal, OperandType.none, 1, false);
    opArgPop = create("arg.pop", OperationCode.argPop, OpCodeType.normal, OperandType.none, 0, true);
    opCall = create("call", OperationCode.call, OpCodeType.controlFlow, OperandType.function_, 0, true);
    opCallTail = create("call.tail", OperationCode.callTail, OpCodeType.controlFlow, OperandType.function_, 0, true);
    opCallIndirect = create("call.indirect", OperationCode.callIndirect, OpCodeType.controlFlow, OperandType.signature, 0, true);
    opInvoke = create("invoke", OperationCode.invoke, OpCodeType.controlFlow, OperandType.function_, 0, false);
    opInvokeTail = create("invoke.tail", OperationCode.invokeTail, OpCodeType.controlFlow, OperandType.function_, 0, false);
    opInvokeIndirect = create("invoke.indirect", OperationCode.invokeIndirect, OpCodeType.controlFlow, OperandType.signature, 0, false);
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
