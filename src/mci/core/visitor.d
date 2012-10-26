module mci.core.visitor;

import mci.core.code.data,
       mci.core.code.fields,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.modules,
       mci.core.typing.types;

/**
 * Abstract visitor class for traversing modules.
 */
public abstract class ModuleVisitor
{
    private bool _run;

    /**
     * Runs the visitor on the given module.
     *
     * Params:
     *  module_ = The module to traverse.
     */
    public final void run(Module module_)
    in
    {
        assert(module_);
        assert(!_run);
    }
    body
    {
        _run = true;

        visit(module_);

        foreach (type; module_.types)
        {
            visit(type.y);

            foreach (field; type.y.members)
                visit(field.y);
        }

        foreach (data; module_.dataBlocks)
            visit(data.y);

        foreach (field; module_.globalFields)
            visit(field.y);

        foreach (field; module_.threadFields)
            visit(field.y);

        foreach (func; module_.functions)
        {
            visit(func.y);

            foreach (param; func.y.parameters)
                visit(param);

            foreach (reg; func.y.registers)
                visit(reg.y);

            foreach (block; func.y.blocks)
            {
                visit(block.y);

                foreach (instr; block.y.stream)
                    visit(instr);
            }
        }
    }

    protected void visit(Module module_)
    in
    {
        assert(module_);
    }
    body
    {
    }

    protected void visit(StructureType type)
    in
    {
        assert(type);
    }
    body
    {
    }

    protected void visit(StructureMember member)
    in
    {
        assert(member);
    }
    body
    {
    }

    protected void visit(DataBlock data)
    in
    {
        assert(data);
    }
    body
    {
    }

    protected void visit(GlobalField field)
    in
    {
        assert(field);
    }
    body
    {
    }

    protected void visit(ThreadField field)
    in
    {
        assert(field);
    }
    body
    {
    }

    protected void visit(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
    }

    protected void visit(Parameter parameter)
    in
    {
        assert(parameter);
    }
    body
    {
    }

    protected void visit(Register register)
    in
    {
        assert(register);
    }
    body
    {
    }

    protected void visit(BasicBlock block)
    in
    {
        assert(block);
    }
    body
    {
    }

    protected void visit(Instruction instruction)
    in
    {
        assert(instruction);
    }
    body
    {
    }
}
