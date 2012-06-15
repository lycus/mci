module mci.core.typing.core;

import mci.core.typing.types;

public abstract class CoreType : Type
{
    private this() pure nothrow
    {
    }
}

public abstract class IntegerType : CoreType
{
    private this() pure nothrow
    {
    }
}

public abstract class FloatingPointType : CoreType
{
    private this() pure nothrow
    {
    }
}

private mixin template DefineCoreType(string type, string name, string base)
{
    mixin("public final class " ~ type ~ "Type : " ~ base ~
          "{" ~
          "    private __gshared " ~ type ~ "Type _instance;" ~
          "" ~
          "    @property public static " ~ type ~ "Type instance() nothrow" ~
          "    out (result)" ~
          "    {" ~
          "        assert(result);" ~
          "    }" ~
          "    body" ~
          "    {" ~
          "        return _instance ? _instance : (_instance = new " ~ type ~ "Type()); " ~
          "    }" ~
          "" ~
          "    private this() pure nothrow" ~
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

/**
 * Indicates whether the given name is a valid
 * name for a core type in the MCI type system.
 * Note that this includes $(PRE void), even
 * though it isn't an actual type.
 *
 * Params:
 *  name = The name to check.
 *
 * Returns:
 *  $(D true) if $(D name) names a core type;
 *  otherwise, $(D false).
 */
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
