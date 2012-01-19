module mci.core.analysis.statistics;

import mci.core.visitor,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.typing.members,
       mci.core.typing.types;

private final class StatisticsVisitor : ModuleVisitor
{
    private size_t _types;
    private size_t _fields;
    private size_t _functions;
    private size_t _parameters;
    private size_t _registers;
    private size_t _blocks;
    private size_t _instructions;

    protected override void visit(StructureType type)
    {
        _types++;
    }

    protected override void visit(Field field)
    {
        _fields++;
    }

    protected override void visit(Function function_)
    {
        _functions++;
    }

    protected override void visit(Parameter parameter)
    {
        _parameters++;
    }

    protected override void visit(Register register)
    {
        _registers++;
    }

    protected override void visit(BasicBlock block)
    {
        _blocks++;
    }

    protected override void visit(Instruction instruction)
    {
        _instructions++;
    }

    @property public size_t types()
    {
        return _types;
    }

    @property public size_t fields()
    {
        return _fields;
    }

    @property public size_t functions()
    {
        return _functions;
    }

    @property public size_t parameters()
    {
        return _parameters;
    }

    @property public size_t registers()
    {
        return _registers;
    }

    @property public size_t blocks()
    {
        return _blocks;
    }

    @property public size_t instructions()
    {
        return _instructions;
    }
}
