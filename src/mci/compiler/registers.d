module mci.compiler.registers;

import mci.core.nullable;

/**
 * Represents a machine-level register.
 */
public interface MachineRegister
{
    /**
     * Gets the kind of register this is.
     *
     * Returns:
     *  The kind of register this is.
     */
    @property public abstract RegisterCategory category() pure nothrow;

    /**
     * Gets the size(s) of this register.
     *
     * Returns:
     *  The size(s) of this register.
     */
    @property public abstract RegisterSize size() pure nothrow;

    /**
     * Gets the name of this register.
     *
     * Returns:
     *  The name of this register.
     */
    @property public abstract string name() pure nothrow;
}

/**
 * Categorizes a register.
 */
public enum RegisterCategory : ubyte
{
    general, /// The register is used for integers and pointer values.
    float_, /// The register is used for floating point values.
    vector, /// The register is used for special vector instructions (SIMD).
    special, /// The register has special meaning (it may hold condition codes, debug data, etc).
}

/**
 * Indicates the size(s) of a register.
 *
 * If only one value from this set of flags is used, that value indicates the
 * size of the register regardless of bitness or other such matters. If a
 * register ORs two of these values together, the lowest value should indicate
 * size in 32-bit mode, while the highest value should indicate the size in
 * 64-bit mode. No more than two values may be used.
 *
 * Note that we set a word to be 32 bits, as opposed to the typical 16 bits.
 */
public enum RegisterSize : ubyte
{
    byte_ = 0x01, /// One byte (i.e. 8 bits).
    hword = 0x02, /// Two bytes (i.e. 16 bits).
    word = 0x04, /// Four bytes (i.e. 32 bits).
    dword = 0x08, /// Eight bytes (i.e. 64 bits).
    qword = 0x10, /// Sixteen bytes (i.e. 128 bits).
    oword = 0x20, /// Thirty-two bytes (i.e. 256 bits).
}

mixin template RegisterBody(string type, string name, RegisterCategory category, ubyte size)
{
    mixin("private __gshared " ~ type ~ " _instance;" ~
          "" ~
          "private this() pure nothrow" ~
          "{" ~
          "}" ~
          "" ~
          "public static " ~ type ~ " opCall()" ~
          "out (result)" ~
          "{" ~
          "    assert(result);" ~
          "}" ~
          "body" ~
          "{" ~
          "    return _instance ? _instance : (_instance = new " ~ type ~ "());" ~
          "}" ~
          "" ~
          "@property public override RegisterCategory category() pure nothrow" ~
          "{" ~
          "    return " ~ category.stringof ~ ";" ~
          "}" ~
          "" ~
          "@property public override RegisterSize size() pure nothrow" ~
          "{" ~
          "    return " ~ (cast(RegisterSize)size).stringof ~ ";" ~
          "}" ~
          "" ~
          "@property public override string name() pure nothrow" ~
          "{" ~
          "    return \"" ~ name ~ "\";" ~
          "}");
}
