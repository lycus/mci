module mci.core.typing.core;

import mci.core.typing.types;

public abstract class CoreType : Type
{
    private this()
    {
    }
}

public abstract class IntegerType : CoreType
{
    private this()
    {
    }
}

public abstract class FloatingPointType : CoreType
{
    private this()
    {
    }
}

private mixin template DefineCoreType(string type, string name, string base)
{
    mixin("public final class " ~ type ~ "Type : " ~ base ~
          "{" ~
          "    private __gshared " ~ type ~ "Type _instance;" ~
          "" ~
          "    @property public static " ~ type ~ "Type instance()" ~
          "    out (result)" ~
          "    {" ~
          "        assert(result);" ~
          "    }" ~
          "    body" ~
          "    {" ~
          "        return _instance ? _instance : (_instance = new " ~ type ~ "Type()); " ~
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

mixin DefineCoreType!("Int8", "int8", "IntegerType");
mixin DefineCoreType!("UInt8", "uint8", "IntegerType");
mixin DefineCoreType!("Int16", "int16", "IntegerType");
mixin DefineCoreType!("UInt16", "uint16", "IntegerType");
mixin DefineCoreType!("Int32", "int32", "IntegerType");
mixin DefineCoreType!("UInt32", "uint32", "IntegerType");
mixin DefineCoreType!("Int64", "int64", "IntegerType");
mixin DefineCoreType!("UInt64", "uint64", "IntegerType");
mixin DefineCoreType!("NativeInt", "int", "IntegerType");
mixin DefineCoreType!("NativeUInt", "uint", "IntegerType");
mixin DefineCoreType!("Float32", "float32", "FloatingPointType");
mixin DefineCoreType!("Float64", "float64", "FloatingPointType");

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
