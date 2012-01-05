module mci.vm.intrinsics.declarations;

import mci.core.common,
       mci.core.container,
       mci.core.code.functions,
       mci.core.code.modules,
       mci.core.typing.cache,
       mci.core.typing.core,
       mci.core.typing.types,
       mci.vm.intrinsics.config;

public __gshared Module intrinsicModule;
public __gshared Lookup!(Function, function_t) intrinsicFunctions;

public __gshared Function mciGetCompiler;
public __gshared Function mciGetArchitecture;
public __gshared Function mciGetOperatingSystem;
public __gshared Function mciGetEndianness;
public __gshared Function mciIs32Bit;

public enum string intrinsicModuleName = "mci";

shared static this()
{
    intrinsicModule = new typeof(intrinsicModule)(intrinsicModuleName);
    auto functions = new NoNullDictionary!(Function, function_t)();

    Function createFunction(string name, void* func, Type returnType, Type[] parameters = null)
    in
    {
        assert(name);
        assert(func);
    }
    body
    {
        auto f = new Function(intrinsicModule, name, returnType, CallingConvention.cdecl, FunctionAttributes.intrinsic);

        foreach (param; parameters)
            f.createParameter(param);

        f.close();

        functions[f] = cast(function_t)func;

        return f;
    }

    mciGetCompiler = createFunction("mci_get_compiler", &mci_get_compiler, UInt8Type.instance);
    mciGetArchitecture = createFunction("mci_get_architecture", &mci_get_architecture, UInt8Type.instance);
    mciGetOperatingSystem = createFunction("mci_get_operating_system", &mci_get_operating_system, UInt8Type.instance);
    mciGetEndianness = createFunction("mci_get_endianness", &mci_get_endianness, UInt8Type.instance);
    mciIs32Bit = createFunction("mci_is_32_bit", &mci_is_32_bit, UInt8Type.instance);

    intrinsicFunctions = functions;
}
