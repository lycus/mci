module mci.compiler.clang.types;

import std.conv,
       mci.compiler.clang.generator,
       mci.core.common,
       mci.core.config,
       mci.core.memory,
       mci.core.code.functions,
       mci.core.typing.core,
       mci.core.typing.types,
       mci.vm.memory.layout;

package string typeToString(ClangCGenerator generator, Type type, string identifier = null, string pointers = null)
in
{
    assert(generator);
}
out (result)
{
    assert(result);
}
body
{
    return match(type,
                 (Int8Type t) => "signed char",
                 (UInt8Type t) => "unsigned char",
                 (Int16Type t) => "signed short",
                 (UInt16Type t) => "unsigned short",
                 (Int32Type t) => "signed int",
                 (UInt32Type t) => "unsigned int",
                 (Int64Type t) => "unsigned long long",
                 (UInt64Type t) => "signed long long",
                 (NativeIntType t) => is32Bit ? "signed int" : "signed long long",
                 (NativeUIntType t) => is32Bit ? "unsigned int" : "unsigned long long",
                 (Float32Type t) => "float",
                 (Float64Type t) => "double",
                 (PointerType t)
                 {
                     auto elem = t.elementType;

                     while (true)
                     {
                         auto pt = cast(PointerType)elem;

                         if (!pt)
                         {
                            if (cast(FunctionPointerType)pt)
                                return typeToString(generator, t.elementType, identifier, pointers ~ '*');
                            else
                                return typeToString(generator, t.elementType) ~ '*';
                         }
                         else
                             elem = pt.elementType;
                     }
                 },
                 (PointerType t) => typeToString(generator, t.elementType, '*' ~ identifier) ~ '*',
                 (StructureType t)
                 {
                     generator.typeQueue.enqueue(t);

                     return "struct " ~ t.module_.name ~ "__" ~ t.name;
                 },
                 (ArrayType t) => "unsigned char*",
                 (VectorType t) => "unsigned char*",
                 (StaticArrayType t)
                 {
                     generator.arrayQueue.enqueue(t);

                     return "struct StaticArray" ~ to!string(computeSize(t.elementType, is32Bit, simdAlignment) * t.elements);
                 },
                 (ReferenceType t) => typeToString(generator, t.elementType) ~ '*',
                 (FunctionPointerType t)
                 {
                     // Welcome to the dirtiest string processing algorithm
                     // ever invented. This attempts to translate IAL function
                     // pointers into C's insane function pointer syntax, and
                     // hopefully gets it right.

                     string s;

                     auto retType = t.returnType;

                     while (true)
                     {
                         auto f = cast(FunctionPointerType)retType;

                         if (!f)
                             break;

                         s ~= "(*";

                         static if (architecture == Architecture.x86 && is32Bit)
                         {
                             switch (f.callingConvention)
                             {
                                 case CallingConvention.cdecl:
                                     s ~= "__attribute__((cdecl)) ";
                                     break;
                                 case CallingConvention.stdCall:
                                     s ~= "__attribute__((stdcall)) ";
                                     break;
                                 default:
                                     break;
                             }
                         }

                         retType = f.returnType;
                     }

                     s = typeToString(generator, retType) ~ ' ' ~ s ~ "(*" ~ pointers;

                     static if (architecture == Architecture.x86 && is32Bit)
                     {
                         switch (t.callingConvention)
                         {
                             case CallingConvention.cdecl:
                                 s ~= " __attribute__((cdecl))";
                                 break;
                             case CallingConvention.stdCall:
                                 s ~= " __attribute__((stdcall))";
                                 break;
                             default:
                                 break;
                         }
                     }

                     if (identifier)
                         s ~= ' ' ~ identifier;

                     s ~= ")(";

                     foreach (i, pt; t.parameterTypes)
                     {
                         s ~= typeToString(generator, pt);

                         if (i < t.parameterTypes.count - 1)
                             s ~= ", ";
                     }

                     s ~= ')';

                     retType = t.returnType;

                     while (true)
                     {
                         auto f = cast(FunctionPointerType)retType;

                         if (!f)
                             break;

                         s ~= ")(";

                         foreach (i, pt; f.parameterTypes)
                         {
                             s ~= typeToString(generator, pt);

                             if (i < f.parameterTypes.count - 1)
                                 s ~= ", ";
                         }

                         s ~= ')';

                         retType = f.returnType;
                     }

                     return s;
                 },
                 (typeof(null) n) => "void");
}
