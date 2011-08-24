module mci.core.typing.core;

import mci.core.typing.types;

public final class Int8Type : TypeBase
{
    @property public override string name()
    {
        return "int8";
    }
}

public final class UInt8Type : TypeBase
{
    @property public override string name()
    {
        return "uint8";
    }
}

public final class Int16Type : TypeBase
{
    @property public override string name()
    {
        return "int16";
    }
}

public final class UInt16Type : TypeBase
{
    @property public override string name()
    {
        return "uint16";
    }
}

public final class Int32Type : TypeBase
{
    @property public override string name()
    {
        return "int32";
    }
}

public final class UInt32Type : TypeBase
{
    @property public override string name()
    {
        return "uint32";
    }
}

public final class Int64Type : TypeBase
{
    @property public override string name()
    {
        return "int64";
    }
}

public final class UInt64Type : TypeBase
{
    @property public override string name()
    {
        return "uint64";
    }
}

public final class Float32Type : TypeBase
{
    @property public override string name()
    {
        return "float32";
    }
}

public final class Float64Type : TypeBase
{
    @property public override string name()
    {
        return "float64";
    }
}
