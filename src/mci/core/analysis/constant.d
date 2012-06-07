module mci.core.analysis.constant;

import std.traits,
       mci.core.common;

private union ConstantData
{
    public long int64;
    public ulong uint64;
    public float float32;
    public double float64;
}

public enum ConstantType : ubyte
{
    int64,
    uint64,
    float32,
    float64,
}

public struct Constant
{
    private ConstantData _data;
    private ConstantType _type;

    @disable this();

    public this(long value) pure nothrow
    {
        _data.int64 = value;
        _type = ConstantType.int64;
    }

    public this(ulong value) pure nothrow
    {
        _data.uint64 = value;
        _type = ConstantType.uint64;
    }

    public this(float value) pure nothrow
    {
        _data.float32 = value;
        _type = ConstantType.float32;
    }

    public this(double value) pure nothrow
    {
        _data.float64 = value;
        _type = ConstantType.float64;
    }

    @property public ConstantType type() pure nothrow
    {
        return _type;
    }

    public Constant opUnary(string op)() pure nothrow
        if (op == "+" || op == "-" || op == "~")
    in
    {
        static if (op == "~")
            assert(_type != ConstantType.float32 && _type != ConstantType.float64);
    }
    body
    {
        static if (op == "~")
        {
            switch (_type)
            {
                case ConstantType.int64:
                    return Constant(~_data.int64);
                case ConstantType.uint64:
                    return Constant(~_data.uint64);
                default:
                    assert(false);
            }
        }
        else
        {
            final switch (_type)
            {
                case ConstantType.int64:
                    return Constant(mixin(op ~ "_data.int64"));
                case ConstantType.uint64:
                    return Constant(mixin(op ~ "_data.uint64"));
                case ConstantType.float32:
                    return Constant(mixin(op ~ "_data.float32"));
                case ConstantType.float64:
                    return Constant(mixin(op ~ "_data.float64"));
            }
        }
    }

    public Constant opBinary(string op)(Constant rhs) pure nothrow
        if (op == "+" || op == "-" || op == "*" || op == "/" ||
            op == "%" || op == "&" || op == "|" || op == "^" ||
            op == "<<" || op == ">>")
    in
    {
        assert(rhs._type == _type);

        static if (op == "&" || op == "|" || op == "^" || op == "<<" || op == ">>")
            assert(_type != ConstantType.float32 && _type != ConstantType.float64);
    }
    body
    {
        // Can't use these on floats.
        static if (op == "&" || op == "|" || op == "^" || op == "<<" || op == ">>")
        {
            switch (_type)
            {
                case ConstantType.int64:
                    return Constant(mixin("_data.int64 " ~ op ~ " rhs._data.int64"));
                case ConstantType.uint64:
                    return Constant(mixin("_data.uint64 " ~ op ~ " rhs._data.uint64"));
                default:
                    assert(false);
            }
        }
        else
        {
            final switch (_type)
            {
                case ConstantType.int64:
                    return Constant(mixin("_data.int64 " ~ op ~ " rhs._data.int64"));
                case ConstantType.uint64:
                    return Constant(mixin("_data.uint64 " ~ op ~ " rhs._data.uint64"));
                case ConstantType.float32:
                    return Constant(mixin("_data.float32 " ~ op ~ " rhs._data.float32"));
                case ConstantType.float64:
                    return Constant(mixin("_data.float64 " ~ op ~ " rhs._data.float64"));
            }
        }
    }

    public hash_t toHash() const nothrow
    {
        final switch (_type)
        {
            case ConstantType.int64:
                return typeid(typeof(_data.int64)).getHash(&_data.int64);
            case ConstantType.uint64:
                return typeid(typeof(_data.uint64)).getHash(&_data.uint64);
            case ConstantType.float32:
                return typeid(typeof(_data.float32)).getHash(&_data.float32);
            case ConstantType.float64:
                return typeid(typeof(_data.float64)).getHash(&_data.float64);
        }
    }

    public equals_t opEquals(Constant rhs) const
    {
        final switch (_type)
        {
            case ConstantType.int64:
                return typeid(typeof(_data.int64)).equals(&_data.int64, &rhs._data.int64);
            case ConstantType.uint64:
                return typeid(typeof(_data.uint64)).equals(&_data.uint64, &rhs._data.uint64);
            case ConstantType.float32:
                return typeid(typeof(_data.float32)).equals(&_data.float32, &rhs._data.float32);
            case ConstantType.float64:
                return typeid(typeof(_data.float64)).equals(&_data.float64, &rhs._data.float64);
        }
    }

    public int opCmp(ref const Constant rhs) const
    {
        final switch (_type)
        {
            case ConstantType.int64:
                return typeid(typeof(_data.int64)).compare(&_data.int64, &rhs._data.int64);
            case ConstantType.uint64:
                return typeid(typeof(_data.uint64)).compare(&_data.uint64, &rhs._data.uint64);
            case ConstantType.float32:
                return typeid(typeof(_data.float32)).compare(&_data.float32, &rhs._data.float32);
            case ConstantType.float64:
                return typeid(typeof(_data.float64)).compare(&_data.float64, &rhs._data.float64);
        }
    }

    // Until the compiler is fixed to allow overloading the unary not operator...
    public Constant not() pure nothrow
    {
        final switch (_type)
        {
            case ConstantType.int64:
                return Constant(cast(long)!_data.int64);
            case ConstantType.uint64:
                return Constant(cast(ulong)!_data.uint64);
            case ConstantType.float32:
                return Constant(cast(float)!_data.float32);
            case ConstantType.float64:
                return Constant(cast(double)!_data.float64);
        }
    }

    public Constant rotate(string direction)(Constant amount) pure nothrow
    in
    {
        assert(amount._type == _type);
        assert(_type != ConstantType.float32 && _type != ConstantType.float64);
    }
    body
    {
        switch (_type)
        {
            case ConstantType.int64:
                return Constant(.rotate!direction(_data.int64, amount._data.int64));
            case ConstantType.uint64:
                return Constant(.rotate!direction(_data.uint64, amount._data.uint64));
            default:
                assert(false);
        }
    }

    public T castTo(T)() pure nothrow
        if (isNumeric!T)
    {
        final switch (_type)
        {
            case ConstantType.int64:
                return cast(T)_data.int64;
            case ConstantType.uint64:
                return cast(T)_data.uint64;
            case ConstantType.float32:
                return cast(T)_data.float32;
            case ConstantType.float64:
                return cast(T)_data.float64;
        }
    }
}
