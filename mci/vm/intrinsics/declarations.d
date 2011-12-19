module mci.vm.intrinsics.declarations;

import mci.core.common,
       mci.core.container,
       mci.core.code.functions,
       mci.core.code.modules,
       mci.core.typing.cache,
       mci.core.typing.core,
       mci.core.typing.types;

public Module intrinsicModule;
public NoNullDictionary!(Function, function_t) intrinsicFunctions;
public enum string intrinsicModuleName = "mci";

static this()
{
    intrinsicModule = new typeof(intrinsicModule)(intrinsicModuleName);
    intrinsicFunctions = new typeof(intrinsicFunctions)();

    Function createFunction(string name, void* func, Type returnType, Type[] parameters = null)
    in
    {
        assert(name);
        assert(func);
    }
    body
    {
        auto f = new Function(intrinsicModule, name, returnType, FunctionAttributes.intrinsic);

        foreach (param; parameters)
            f.createParameter(param);

        f.close();

        intrinsicFunctions[f] = cast(function_t)func;

        return f;
    }
}
