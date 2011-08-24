module mci.core.typing.core;

import mci.core.typing.types;

private mixin template CoreType(string type, string name)
{
    mixin("public final class " ~ type ~ "Type : Type" ~
          "{" ~
          "    @property public override string name()" ~
          "    {" ~
          "        return \"" ~ name ~ "\";" ~
          "    }"
          "}");
}

mixin CoreType!("Int8", "int8");
mixin CoreType!("UInt8", "uint8");
mixin CoreType!("Int16", "int16");
mixin CoreType!("UInt16", "uint16");
mixin CoreType!("Int32", "int32");
mixin CoreType!("UInt32", "uint32");
mixin CoreType!("Int64", "int64");
mixin CoreType!("UInt64", "uint64");
mixin CoreType!("Float32", "float32");
mixin CoreType!("Float64", "float64");
