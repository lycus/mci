module mci.linker.clash;

import std.string,
       mci.core.code.modules,
       mci.core.typing.types,
       mci.linker.exception;

/**
 * Represents the type of name clash that occurred.
 */
public enum NameType : ubyte
{
    type, /// Two type names clashed.
    function_, /// Two function names clashed.
}

/**
 * Represents a linker name clash resolver.
 */
public interface NameClashResolver
{
    /**
     * Attempts to resolve a name clash.
     *
     * Params:
     *  module_ = The module being constructed as a result of the linking.
     *  type = The type of the name clash.
     *  name = The name that clashed.
     *  module1 = The first module containing $(D name).
     *  module2 = The second module containing $(D name).
     *
     * Returns:
     *  The resolved name.
     *
     * Throws:
     *  $(D LinkerException) if the clash could not be resolved.
     */
    public string resolveNameClash(Module module_, NameType type, string name, Module module1, Module module2)
    in
    {
        assert(module_);
        assert(name);
        assert(module1);
        assert(module2);
    }
    out (result)
    {
        assert(result);
    }
}

/**
 * Simply throws an exception on a name clash.
 */
public final class ErrorResolver : NameClashResolver
{
    public string resolveNameClash(Module module_, NameType type, string name, Module module1, Module module2)
    {
        string typeStr;

        final switch (type)
        {
            case NameType.type:
                typeStr = "type";
                break;
            case NameType.function_:
                typeStr = "function";
                break;
        }

        throw new LinkerException(format("Clash between %s names '%s'/'%s' and '%s'/'%s'.", typeStr, module1.name, name, module2.name, name));
    }
}

/**
 * Attempts to resolve name clashes through simplistic renaming.
 */
public final class RenameResolver : NameClashResolver
{
    public string resolveNameClash(Module module_, NameType type, string name, Module module1, Module module2)
    {
        auto resolvedName = format("%s_%s", module_.name, name);

        final switch (type)
        {
            case NameType.type:
                if (module_.types.get(resolvedName))
                    resolvedName ~= "_T";

                break;
            case NameType.function_:
                if (module_.functions.get(resolvedName))
                    resolvedName ~= "_F";

                break;
        }

        return resolvedName;
    }
}
