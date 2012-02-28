module mci.core.analysis.constant;

import std.traits,
       mci.core.common;

private union ConstantData
{
    long int64;
    ulong uint64;
    float float32;
    double float64;
}

public enum ConstantType : ubyte
{
    int64,
    uint64,
    float32,
    float64,
}

public final class Constant
{
    private ConstantData _data;
    private ConstantType _type;

    public this(long value)
    {
        _data.int64 = value;
        _type = ConstantType.int64;
    }

    public this(ulong value)
    {
        _data.uint64 = value;
        _type = ConstantType.uint64;
    }

    public this(float value)
    {
        _data.float32 = value;
        _type = ConstantType.float32;
    }

    public this(double value)
    {
        _data.float64 = value;
        _type = ConstantType.float64;
    }

    @property public ConstantType type()
    {
        return _type;
    }

    public Constant opUnary(string op)()
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
                    return new Constant(~_data.int64);
                case ConstantType.uint64:
                    return new Constant(~_data.uint64);
                default:
                    assert(false);
            }
        }
        else
        {
            final switch (_type)
            {
                case ConstantType.int64:
                    return new Constant(mixin(op ~ "_data.int64"));
                case ConstantType.uint64:
                    return new Constant(mixin(op ~ "_data.uint64"));
                case ConstantType.float32:
                    return new Constant(mixin(op ~ "_data.float32"));
                case ConstantType.float64:
                    return new Constant(mixin(op ~ "_data.float64"));
            }
        }
    }

    public Constant opBinary(string op)(Constant rhs)
        if (op == "+" || op == "-" || op == "*" || op == "/" ||
            op == "%" || op == "&" || op == "|" || op == "^" ||
            op == "<<" || op == ">>")
    in
    {
        assert(rhs);
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
                    // Special case for >>> because D's built-in >> is completely retarded.
                    static if (op == ">>")
                        return new Constant(_data.int64 >>> rhs._data.int64);
                    else
                        return new Constant(mixin("_data.int64 " ~ op ~ " rhs._data.int64"));
                case ConstantType.uint64:
                    return new Constant(mixin("_data.uint64 " ~ op ~ " rhs._data.uint64"));
                default:
                    assert(false);
            }
        }
        else
        {
            final switch (_type)
            {
                case ConstantType.int64:
                    return new Constant(mixin("_data.int64 " ~ op ~ " rhs._data.int64"));
                case ConstantType.uint64:
                    return new Constant(mixin("_data.uint64 " ~ op ~ " rhs._data.uint64"));
                case ConstantType.float32:
                    return new Constant(mixin("_data.float32 " ~ op ~ " rhs._data.float32"));
                case ConstantType.float64:
                    return new Constant(mixin("_data.float64 " ~ op ~ " rhs._data.float64"));
            }
        }
    }

    public final override equals_t opEquals(Object o)
    {
        if (this is o)
            return true;

        if (auto constant = cast(Constant)o)
        {
            final switch (_type)
            {
                case ConstantType.int64:
                    return typeid(typeof(_data.int64)).equals(&_data.int64, &constant._data.int64);
                case ConstantType.uint64:
                    return typeid(typeof(_data.uint64)).equals(&_data.uint64, &constant._data.uint64);
                case ConstantType.float32:
                    return typeid(typeof(_data.float32)).equals(&_data.float32, &constant._data.float32);
                case ConstantType.float64:
                    return typeid(typeof(_data.float64)).equals(&_data.float64, &constant._data.float64);
            }
        }

        return false;
    }

    public final override hash_t toHash()
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

    public final override int opCmp(Object o)
    {
        if (this is o)
            return 0;

        if (auto constant = cast(Constant)o)
        {
            final switch (_type)
            {
                case ConstantType.int64:
                    return typeid(typeof(_data.int64)).compare(&_data.int64, &constant._data.int64);
                case ConstantType.uint64:
                    return typeid(typeof(_data.uint64)).compare(&_data.uint64, &constant._data.uint64);
                case ConstantType.float32:
                    return typeid(typeof(_data.float32)).compare(&_data.float32, &constant._data.float32);
                case ConstantType.float64:
                    return typeid(typeof(_data.float64)).compare(&_data.float64, &constant._data.float64);
            }
        }

        return 1;
    }

    // Until the compiler is fixed to allow overloading the unary not operator...
    public Constant not()
    out (result)
    {
        assert(result);
    }
    body
    {
        final switch (_type)
        {
            case ConstantType.int64:
                return new Constant(cast(long)!_data.int64);
            case ConstantType.uint64:
                return new Constant(cast(ulong)!_data.uint64);
            case ConstantType.float32:
                return new Constant(cast(float)!_data.float32);
            case ConstantType.float64:
                return new Constant(cast(double)!_data.float64);
        }
    }

    public Constant rotate(string direction)(Constant amount)
    in
    {
        assert(amount);
        assert(amount._type == _type);
        assert(_type != ConstantType.float32 && _type != ConstantType.float64);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        switch (_type)
        {
            case ConstantType.int64:
                return new Constant(.rotate!direction(_data.int64, amount._data.int64));
            case ConstantType.uint64:
                return new Constant(.rotate!direction(_data.uint64, amount._data.uint64));
            default:
                assert(false);
        }
    }

    public T castTo(T)()
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