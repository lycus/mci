module mci.vm.intrinsics.declarations;

import mci.core.code.functions,
       mci.core.code.modules,
       mci.core.typing.cache,
       mci.core.typing.core,
       mci.core.typing.types;

public Module intrinsicModule;
public enum string intrinsicModuleName = "mci";

static this()
{
    intrinsicModule = new Module(intrinsicModuleName);

    Function createFunction(string name, Type returnType, Type[] parameters = null)
    in
    {
        assert(name);
    }
    body
    {
        auto func = new Function(intrinsicModule, name, returnType, FunctionAttributes.intrinsic);

        foreach (param; parameters)
            func.createParameter(param);

        return func;
    }
}
