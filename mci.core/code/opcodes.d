module mci.core.code.opcodes;

import mci.core.container,
       mci.core.tuple,
       mci.core.code.instructions,
       mci.core.typing.members,
       mci.core.typing.types;

public enum OpCodeType : ubyte
{
    normal = 0,
    controlFlow = 1,
    noOperation = 2,
    annotation = 3,
}

public enum OperandType : ubyte
{
    none = 0,
    int8 = 1,
    uint8 = 2,
    int16 = 3,
    uint16 = 4,
    int32 = 5,
    uint32 = 6,
    int64 = 7,
    uint64 = 8,
    float32 = 9,
    float64 = 10,
    bytes = 11,
    label = 12,
    type = 13,
    field = 14,
    method = 15,
    registers = 16,
}

public static TypeInfo operandToTypeInfo(OperandType operandType)
{
    final switch (operandType)
    {
        case OperandType.none:
            return null;
            
        case OperandType.bytes:
            return typeid(Object);
            
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
            
        case OperandType.label:
            return typeid(string);
            
        case OperandType.type:
            return typeid(Type);
            
        case OperandType.field:
            return typeid(Field);
            
        case OperandType.method:
             assert(false, "Not implemented."); // TODO
            
        case OperandType.registers:
            return typeid(Iterable!(Tuple!(string, Register)));
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
    
    package this(string name, ubyte code, OpCodeType type, OperandType operandType,
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

public static __gshared OpCode opNop;
public static __gshared OpCode opComment;
public static __gshared OpCode opDead;
public static __gshared OpCode opRaw;
public static __gshared OpCode opLoadI8;
public static __gshared OpCode opLoadUI8;
public static __gshared OpCode opLoadI16;
public static __gshared OpCode opLoadUI16;
public static __gshared OpCode opLoadI32;
public static __gshared OpCode opLoadUI32;
public static __gshared OpCode opLoadI64;
public static __gshared OpCode opLoadUI64;
public static __gshared OpCode opLoadF32;
public static __gshared OpCode opLoadF64;
public static __gshared OpCode opLoadFunc;
public static __gshared OpCode opLoadNull;
public static __gshared OpCode opLoadSize;
public static __gshared OpCode opCopy;
public static __gshared OpCode opAdd;
public static __gshared OpCode opSub;
public static __gshared OpCode opMul;
public static __gshared OpCode opDiv;
public static __gshared OpCode opRem;
public static __gshared OpCode opNeg;
public static __gshared OpCode opAnd;
public static __gshared OpCode opOr;
public static __gshared OpCode opXOr;
public static __gshared OpCode opNot;
public static __gshared OpCode opShL;
public static __gshared OpCode opShR;
public static __gshared OpCode opConv;
public static __gshared OpCode opConvI8;
public static __gshared OpCode opConvUI8;
public static __gshared OpCode opConvI16;
public static __gshared OpCode opConvUI16;
public static __gshared OpCode opConvI32;
public static __gshared OpCode opConvUI32;
public static __gshared OpCode opConvI64;
public static __gshared OpCode opConvUI64;
public static __gshared OpCode opConvIN;
public static __gshared OpCode opConvUIN;
public static __gshared OpCode opConvF32;
public static __gshared OpCode opConvF64;
public static __gshared OpCode opConvFN;
public static __gshared OpCode opMemAlloc;
public static __gshared OpCode opMemNew;
public static __gshared OpCode opMemFree;
public static __gshared OpCode opMemDelete;
public static __gshared OpCode opMemGet;
public static __gshared OpCode opMemSet;
public static __gshared OpCode opMemAddr;
public static __gshared OpCode opFieldGet;
public static __gshared OpCode opFieldSet;
public static __gshared OpCode opFieldAddr;
public static __gshared OpCode opCmpEq;
public static __gshared OpCode opCmpGt;
public static __gshared OpCode opCmpLt;
public static __gshared OpCode opCmpGtEq;
public static __gshared OpCode opCmpLtEq;
public static __gshared OpCode opArgPush;
public static __gshared OpCode opArgPop;
public static __gshared OpCode opResult;
public static __gshared OpCode opCall;
public static __gshared OpCode opCallTail;
public static __gshared OpCode opJump;
public static __gshared OpCode opJumpTrue;
public static __gshared OpCode opJumpFalse;
public static __gshared OpCode opLeave;
public static __gshared OpCode opReturn;
public static __gshared OpCode opPhi;

public static __gshared Iterable!OpCode allOpCodes;

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
    opLoadFunc = create("load.func", OpCodeType.normal, OperandType.method, 0, true);
    opLoadNull = create("load.null", OpCodeType.normal, OperandType.none, 0, true);
    opLoadSize = create("load.size", OpCodeType.normal, OperandType.type, 0, true);
    opCopy = create("copy", OpCodeType.normal, OperandType.none, 1, true);
    opAdd = create("add", OpCodeType.normal, OperandType.none, 2, true);
    opSub = create("sub", OpCodeType.normal, OperandType.none, 2, true);
    opMul = create("mul", OpCodeType.normal, OperandType.none, 2, true);
    opDiv = create("div", OpCodeType.normal, OperandType.none, 2, true);
    opRem = create("rem", OpCodeType.normal, OperandType.none, 2, true);
    opRem = create("rem", OpCodeType.normal, OperandType.none, 1, true);
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
    opMemNew = create("mem.new", OpCodeType.normal, OperandType.type, 0, true);
    opMemFree = create("mem.free", OpCodeType.normal, OperandType.none, 1, false);
    opMemDelete = create("mem.delete", OpCodeType.normal, OperandType.none, 1, false);
    opMemGet = create("mem.get", OpCodeType.normal, OperandType.none, 1, true);
    opMemSet = create("mem.set", OpCodeType.normal, OperandType.none, 2, false);
    opMemAddr = create("mem.addr", OpCodeType.normal, OperandType.none, 1, true);
    opFieldGet = create("field.get", OpCodeType.normal, OperandType.field, 1, true);
    opFieldSet = create("field.set", OpCodeType.normal, OperandType.field, 2, false);
    opFieldAddr = create("field.addr", OpCodeType.normal, OperandType.field, 1, true);
    opCmpEq = create("cmp.eq", OpCodeType.normal, OperandType.none, 2, true);
    opCmpGt = create("cmp.gt", OpCodeType.normal, OperandType.none, 2, true);
    opCmpLt = create("cmp.lt", OpCodeType.normal, OperandType.none, 2, true);
    opCmpGtEq = create("cmp.gteq", OpCodeType.normal, OperandType.none, 2, true);
    opCmpLtEq = create("cmp.lteq", OpCodeType.normal, OperandType.none, 2, true);
    opArgPush = create("arg.push", OpCodeType.normal, OperandType.none, 1, false);
    opArgPop = create("arg.pop", OpCodeType.normal, OperandType.none, 0, true);
    opCall = create("call", OpCodeType.controlFlow, OperandType.method, 0, true);
    opCallTail = create("call.tail", OpCodeType.controlFlow, OperandType.method, 0, true);
    opJump = create("jump", OpCodeType.controlFlow, OperandType.label, 0, false);
    opJumpTrue = create("jump.true", OpCodeType.controlFlow, OperandType.label, 1, false);
    opJumpFalse = create("jump.false", OpCodeType.controlFlow, OperandType.label, 1, false);
    opLeave = create("leave", OpCodeType.controlFlow, OperandType.none, 0, false);
    opReturn = create("return", OpCodeType.controlFlow, OperandType.none, 1, false);
    opPhi = create("phi", OpCodeType.normal, OperandType.registers, 0, true);
    
    allOpCodes = opCodes;
}
