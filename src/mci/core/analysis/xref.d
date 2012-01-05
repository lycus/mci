module mci.core.analysis.xref;

import mci.core.container,
       mci.core.visitor,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.modules;

public abstract class XRefVisitor: ModuleVisitor
{
    // TODO: Replace this with a hash set as soon this is implemented.
    private Dictionary!(Module, int) _modules; 

    public this()
    {
        _modules = new typeof(_modules)();
    }

    protected override void visit(Instruction instruction)
    {
        if (auto func = instruction.operand.peek!Function())
        {
            auto module_ = func.module_;

            if (_modules.get(module_))
                return;

            _modules.add(module_, 0);
            run(module_);
        }
    }
}
