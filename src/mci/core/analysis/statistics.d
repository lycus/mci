module mci.core.analysis.statistics;

import mci.core.visitor,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.typing.members,
       mci.core.typing.types;

/**
 * Gathers various statistics about a module.
 */
private final class StatisticsVisitor : ModuleVisitor
{
    private size_t _types;
    private size_t _fields;
    private size_t _functions;
    private size_t _parameters;
    private size_t _registers;
    private size_t _blocks;
    private size_t _instructions;

    protected override void visit(StructureType type) pure nothrow
    {
        _types++;
    }

    protected override void visit(Field field) pure nothrow
    {
        _fields++;
    }

    protected override void visit(Function function_) pure nothrow
    {
        _functions++;
    }

    protected override void visit(Parameter parameter) pure nothrow
    {
        _parameters++;
    }

    protected override void visit(Register register) pure nothrow
    {
        _registers++;
    }

    protected override void visit(BasicBlock block) pure nothrow
    {
        _blocks++;
    }

    protected override void visit(Instruction instruction) pure nothrow
    {
        _instructions++;
    }

    /**
     * Gets the amount of types in the module.
     *
     * Returns:
     *  The amount of types in the module.
     */
    @property public size_t types() pure nothrow
    {
        return _types;
    }

    /**
     * Gets the amount of fields in the module.
     *
     * Returns:
     *  The amount of fields in the module.
     */
    @property public size_t fields() pure nothrow
    {
        return _fields;
    }

    /**
     * Gets the amount of functions in the module.
     *
     * Returns:
     *  The amount of functions in the module.
     */
    @property public size_t functions() pure nothrow
    {
        return _functions;
    }

    /**
     * gets the amount of parameters in the module.
     *
     * Returns:
     *  The amount of parameters in the module.
     */
    @property public size_t parameters() pure nothrow
    {
        return _parameters;
    }

    /**
     * Gets the amount of registers in the module.
     *
     * Returns:
     *  The amount of registers in the module.
     */
    @property public size_t registers() pure nothrow
    {
        return _registers;
    }

    /**
     * Gets the amount of basic blocks in the module.
     *
     * Returns:
     *  The amount of basic blocks in the module.
     */
    @property public size_t blocks() pure nothrow
    {
        return _blocks;
    }

    /**
     * Gets the amount of instructions in the module.
     *
     * Returns:
     *  The amount of instructions in the module.
     */
    @property public size_t instructions() pure nothrow
    {
        return _instructions;
    }
}
