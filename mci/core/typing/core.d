module mci.core.typing.core;

import mci.core.typing.types;

public abstract class CoreType : Type
{
}

private mixin template DefineCoreType(string type, string name)
{
    mixin("public final class " ~ type ~ "Type : CoreType" ~
          "{" ~
          "    private static " ~ type ~ "Type _instance;" ~
          "" ~
          "    @property public static " ~ type ~ "Type instance()" ~
          "    out (result)" ~
          "    {" ~
          "        assert(result);" ~
          "    }" ~
          "    body" ~
          "    {" ~
          "        return _instance; " ~
          "    }" ~
          "" ~
          "    static this()" ~
          "    {" ~
          "        _instance = new " ~ type ~ "Type();" ~
          "    }" ~
          "" ~
          "    private this()" ~
          "    {" ~
          "    }" ~
          "" ~
          "    @property public override string name()" ~
          "    {" ~
          "        return \"" ~ name ~ "\";" ~
          "    }"
          "}");
}

mixin DefineCoreType!("Int8", "int8");
mixin DefineCoreType!("UInt8", "uint8");
mixin DefineCoreType!("Int16", "int16");
mixin DefineCoreType!("UInt16", "uint16");
mixin DefineCoreType!("Int32", "int32");
mixin DefineCoreType!("UInt32", "uint32");
mixin DefineCoreType!("Int64", "int64");
mixin DefineCoreType!("UInt64", "uint64");
mixin DefineCoreType!("NativeInt", "int");
mixin DefineCoreType!("NativeUInt", "uint");
mixin DefineCoreType!("Float32", "float32");
mixin DefineCoreType!("Float64", "float64");

public bool isCoreTypeName(string name)
in
{
    assert(name);
}
body
{
    return name == "void" ||
           name == Int8Type.instance.name ||
           name == UInt8Type.instance.name ||
           name == Int16Type.instance.name ||
           name == UInt16Type.instance.name ||
           name == Int32Type.instance.name ||
           name == UInt32Type.instance.name ||
           name == Int64Type.instance.name ||
           name == UInt64Type.instance.name ||
           name == NativeIntType.instance.name ||
           name == NativeUIntType.instance.name ||
           name == Float32Type.instance.name ||
           name == Float64Type.instance.name;
}
