module mci.assembler.generation.data;

import std.algorithm,
       std.conv,
       mci.core.container,
       mci.core.code.data,
       mci.core.code.metadata,
       mci.core.code.modules,
       mci.assembler.parsing.ast,
       mci.assembler.generation.driver,
       mci.assembler.generation.exception,
       mci.assembler.generation.modules;

public DataBlock generateDataBlock(DataBlockDeclarationNode node, Module module_, ModuleManager manager)
in
{
    assert(node);
    assert(module_);
    assert(manager);
}
body
{
    if (auto data = module_.dataBlocks.get(node.name.name))
        throw new GenerationException("Data block " ~ data.toString() ~ " already defined.", node.location);

    auto values = new List!ubyte();

    foreach (literal; node.bytes.values)
    {
        string value;
        uint radix;

        if (startsWith(literal.value, "0x"))
        {
            value = literal.value[2 .. $];
            radix = 16;
        }
        else
        {
            value = literal.value;
            radix = 10;
        }

        values.add(parse!ubyte(value));
    }

    auto data = new DataBlock(module_, node.name.name, values);

    if (node.metadata)
        foreach (md; node.metadata.metadata)
            data.metadata.add(MetadataPair(md.key.name, md.value.name));

    return data;
}

public DataBlock resolveDataBlock(DataBlockReferenceNode node, Module module_, ModuleManager manager)
in
{
    assert(node);
    assert(module_);
    assert(manager);
}
out (result)
{
    assert(result);
}
body
{
    auto mod = node.moduleName ? resolveModule(node.moduleName, manager) : module_;

    if (auto data = mod.dataBlocks.get(node.name.name))
        return *data;

    throw new GenerationException("Unknown data block " ~ mod.toString() ~ "/'" ~ node.name.name ~ "'.", node.location);
}
