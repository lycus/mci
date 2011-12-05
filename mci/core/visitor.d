module mci.core.visitor;

import mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.modules,
       mci.core.typing.members,
       mci.core.typing.types;

public abstract class ModuleVisitor
{
    public final void run(Module module_)
    in
    {
        assert(module_);
    }
    body
    {
        visit(module_);

        foreach (type; module_.types)
        {
            visit(type.y);

            foreach (field; type.y.fields)
                visit(field.y);
        }

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

                foreach (instr; block.y.instructions)
                    visit(instr);
            }
        }
    }

    public void visit(Module module_)
    in
    {
        assert(module_);
    }
    body
    {
    }

    public void visit(StructureType type)
    in
    {
        assert(type);
    }
    body
    {
    }

    public void visit(Field field)
    in
    {
        assert(field);
    }
    body
    {
    }

    public void visit(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
    }

    public void visit(Parameter parameter)
    in
    {
        assert(parameter);
    }
    body
    {
    }

    public void visit(Register register)
    in
    {
        assert(register);
    }
    body
    {
    }

    public void visit(BasicBlock block)
    in
    {
        assert(block);
    }
    body
    {
    }

    public void visit(Instruction instruction)
    in
    {
        assert(instruction);
    }
    body
    {
    }
}
