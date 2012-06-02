module mci.compiler.emulation;

import mci.core.common,
       mci.core.math;

// This module primarily serves to emulate 64-bit operations on
// 32-bit machines.

private mixin template UnaryEmulator(string name, string result, string param1, string expr)
{
    mixin("public extern (C) " ~ result ~ " mci_emul_" ~ name ~ "(" ~ param1 ~ " a)" ~
          "{" ~
          "    return " ~ expr ~ ";" ~
          "}");
}

private mixin template BinaryEmulator(string name, string result, string param1, string param2, string expr)
{
    mixin("public extern (C) " ~ result ~ " mci_emul_" ~ name ~ "(" ~ param1 ~ " a, " ~ param2 ~ " b)" ~
          "{" ~
          "    return " ~ expr ~ ";" ~
          "}");
}

// Signed 64-bit integers.

mixin BinaryEmulator!("int64_ari_add", "long", "long", "long", "a + b");
mixin BinaryEmulator!("int64_ari_sub", "long", "long", "long", "a - b");
mixin BinaryEmulator!("int64_ari_mul", "long", "long", "long", "a * b");
mixin BinaryEmulator!("int64_ari_div", "long", "long", "long", "a / b");
mixin BinaryEmulator!("int64_ari_rem", "long", "long", "long", "a % b");
mixin UnaryEmulator!("int64_ari_neg", "long", "long", "-a");

mixin BinaryEmulator!("int64_bit_and", "long", "long", "long", "a & b");
mixin BinaryEmulator!("int64_bit_or", "long", "long", "long", "a | b");
mixin BinaryEmulator!("int64_bit_xor", "long", "long", "long", "a ^ b");
mixin UnaryEmulator!("int64_bit_neg", "long", "long", "~a");

mixin UnaryEmulator!("int64_not", "size_t", "long", "!a");
mixin BinaryEmulator!("int64_shl", "long", "long", "size_t", "a << b");
mixin BinaryEmulator!("int64_shr", "long", "long", "size_t", "a >> b");
mixin BinaryEmulator!("int64_rol", "long", "long", "size_t", "rol(a, cast(uint)b)");
mixin BinaryEmulator!("int64_ror", "long", "long", "size_t", "ror(a, cast(uint)b)");

mixin UnaryEmulator!("int64_conv_to_int8", "byte", "long", "cast(byte)a");
mixin UnaryEmulator!("int64_conv_to_uint8", "ubyte", "long", "cast(ubyte)a");
mixin UnaryEmulator!("int64_conv_to_int16", "short", "long", "cast(short)a");
mixin UnaryEmulator!("int64_conv_to_uint16", "ushort", "long", "cast(ushort)a");
mixin UnaryEmulator!("int64_conv_to_int32", "int", "long", "cast(int)a");
mixin UnaryEmulator!("int64_conv_to_uint32", "uint", "long", "cast(uint)a");
mixin UnaryEmulator!("int64_conv_to_int64", "long", "long", "a");
mixin UnaryEmulator!("int64_conv_to_uint64", "ulong", "long", "a");
mixin UnaryEmulator!("int64_conv_to_int", "isize_t", "long", "cast(isize_t)a");
mixin UnaryEmulator!("int64_conv_to_uint", "size_t", "long", "cast(size_t)a");
mixin UnaryEmulator!("int64_conv_to_float32", "float", "long", "a");
mixin UnaryEmulator!("int64_conv_to_float64", "double", "long", "a");

mixin UnaryEmulator!("int64_conv_from_int8", "long", "byte", "a");
mixin UnaryEmulator!("int64_conv_from_uint8", "long", "ubyte", "a");
mixin UnaryEmulator!("int64_conv_from_int16", "long", "short", "a");
mixin UnaryEmulator!("int64_conv_from_uint16", "long", "ushort", "a");
mixin UnaryEmulator!("int64_conv_from_int32", "long", "int", "a");
mixin UnaryEmulator!("int64_conv_from_uint32", "long", "uint", "a");
mixin UnaryEmulator!("int64_conv_from_int64", "long", "long", "a");
mixin UnaryEmulator!("int64_conv_from_uint64", "long", "ulong", "a");
mixin UnaryEmulator!("int64_conv_from_int", "long", "isize_t", "a");
mixin UnaryEmulator!("int64_conv_from_uint", "long", "size_t", "a");
mixin UnaryEmulator!("int64_conv_from_float32", "long", "float", "cast(long)a");
mixin UnaryEmulator!("int64_conv_from_float64", "long", "double", "cast(long)a");

// Unsigned 64-bit integers.

mixin BinaryEmulator!("uint64_ari_add", "ulong", "ulong", "ulong", "a + b");
mixin BinaryEmulator!("uint64_ari_sub", "ulong", "ulong", "ulong", "a - b");
mixin BinaryEmulator!("uint64_ari_mul", "ulong", "ulong", "ulong", "a * b");
mixin BinaryEmulator!("uint64_ari_div", "ulong", "ulong", "ulong", "a / b");
mixin BinaryEmulator!("uint64_ari_rem", "ulong", "ulong", "ulong", "a % b");
mixin UnaryEmulator!("uint64_ari_neg", "ulong", "ulong", "-a");

mixin BinaryEmulator!("uint64_bit_and", "ulong", "ulong", "ulong", "a & b");
mixin BinaryEmulator!("uint64_bit_or", "ulong", "ulong", "ulong", "a | b");
mixin BinaryEmulator!("uint64_bit_xor", "ulong", "ulong", "ulong", "a ^ b");
mixin UnaryEmulator!("uint64_bit_neg", "ulong", "ulong", "~a");

mixin UnaryEmulator!("uint64_not", "size_t", "ulong", "!a");
mixin BinaryEmulator!("uint64_shl", "ulong", "ulong", "size_t", "a << b");
mixin BinaryEmulator!("uint64_shr", "ulong", "ulong", "size_t", "a >> b");
mixin BinaryEmulator!("uint64_rol", "ulong", "ulong", "size_t", "rol(a, cast(uint)b)");
mixin BinaryEmulator!("uint64_ror", "ulong", "ulong", "size_t", "ror(a, cast(uint)b)");

mixin UnaryEmulator!("uint64_conv_to_int8", "byte", "ulong", "cast(byte)a");
mixin UnaryEmulator!("uint64_conv_to_uint8", "ubyte", "ulong", "cast(ubyte)a");
mixin UnaryEmulator!("uint64_conv_to_int16", "short", "ulong", "cast(short)a");
mixin UnaryEmulator!("uint64_conv_to_uint16", "ushort", "ulong", "cast(ushort)a");
mixin UnaryEmulator!("uint64_conv_to_int32", "int", "ulong", "cast(int)a");
mixin UnaryEmulator!("uint64_conv_to_uint32", "uint", "ulong", "cast(uint)a");
mixin UnaryEmulator!("uint64_conv_to_int64", "long", "ulong", "a");
mixin UnaryEmulator!("uint64_conv_to_uint64", "ulong", "ulong", "a");
mixin UnaryEmulator!("uint64_conv_to_int", "isize_t", "ulong", "cast(isize_t)a");
mixin UnaryEmulator!("uint64_conv_to_uint", "size_t", "ulong", "cast(size_t)a");
mixin UnaryEmulator!("uint64_conv_to_float32", "float", "ulong", "a");
mixin UnaryEmulator!("uint64_conv_to_float64", "double", "ulong", "a");

mixin UnaryEmulator!("uint64_conv_from_int8", "ulong", "byte", "a");
mixin UnaryEmulator!("uint64_conv_from_uint8", "ulong", "ubyte", "a");
mixin UnaryEmulator!("uint64_conv_from_int16", "ulong", "short", "a");
mixin UnaryEmulator!("uint64_conv_from_uint16", "ulong", "ushort", "a");
mixin UnaryEmulator!("uint64_conv_from_int32", "ulong", "int", "a");
mixin UnaryEmulator!("uint64_conv_from_uint32", "ulong", "uint", "a");
mixin UnaryEmulator!("uint64_conv_from_int64", "ulong", "long", "a");
mixin UnaryEmulator!("uint64_conv_from_uint64", "ulong", "ulong", "a");
mixin UnaryEmulator!("uint64_conv_from_int", "ulong", "isize_t", "a");
mixin UnaryEmulator!("uint64_conv_from_uint", "ulong", "size_t", "a");
mixin UnaryEmulator!("uint64_conv_from_float32", "ulong", "float", "cast(ulong)a");
mixin UnaryEmulator!("uint64_conv_from_float64", "ulong", "double", "cast(ulong)a");
