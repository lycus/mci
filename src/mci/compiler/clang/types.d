module mci.compiler.clang.types;

import mci.core.common,
       mci.core.config,
       mci.core.typing.core,
       mci.core.typing.types;

package string typeToString(Type type, string identifier = null)
in
{
    assert(type);
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
                 (PointerType t) => typeToString(t.elementType, '*' ~ identifier) ~ '*',
                 (StructureType t) => "struct " ~ t.module_.name ~ "__" ~ t.name,
                 (ArrayType t) => "unsigned char*",
                 (VectorType t) => "unsigned char*",
                 (ReferenceType t) => "unsigned char*",
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

                         s ~= '(';

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

                         s ~= '*';
                         retType = f.returnType;
                     }

                     s = (retType ? typeToString(retType) : "void") ~ ' ' ~ s;

                     static if (architecture == Architecture.x86 && is32Bit)
                     {
                         switch (t.callingConvention)
                         {
                             case CallingConvention.cdecl:
                                 s = "__attribute__((cdecl)) " ~ s;
                                 break;
                             case CallingConvention.stdCall:
                                 s = "__attribute__((stdcall)) " ~ s;
                                 break;
                             default:
                                 break;
                         }
                     }

                     s ~= "(*";

                     if (identifier)
                         s ~= '_' ~ identifier;

                     s ~= ")(";

                     foreach (i, pt; t.parameterTypes)
                     {
                         s ~= typeToString(pt);

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
                             s ~= typeToString(pt);

                             if (i < f.parameterTypes.count - 1)
                                 s ~= ", ";
                         }

                         s ~= ')';

                         retType = f.returnType;
                     }

                     return s;
                 });
}
