module mci.vm.intrinsics.declarations;

import mci.core.code.functions,
       mci.core.code.modules,
       mci.core.typing.cache,
       mci.core.typing.core,
       mci.core.typing.types;

public Module intrinsicModule;
public enum string intrinsicModuleName = "mci";

public Function mciMemoryAllocate;
public Function mciMemoryZeroAllocate;
public Function mciMemoryReallocate;
public Function mciMemoryFree;

public Function mciGetStdIn;
public Function mciGetStdErr;
public Function mciGetStdOut;
public Function mciFileOpen;
public Function mciFileClose;
public Function mciFileFP;
public Function mciFileEOF;
public Function mciFileIsOpen;
public Function mciFilePosition;
public Function mciFileWrite;
public Function mciFileWriteLine;
public Function mciFileRead;
public Function mciFileReadLine;

static this()
{
    intrinsicModule = new Module(intrinsicModuleName);

    Function createFunction(string name, Type returnType, Type[] parameters = null)
    in
    {
        assert(name);
        assert(returnType);
    }
    body
    {
        auto func = new Function(intrinsicModule, name, returnType, FunctionAttributes.intrinsic, CallingConvention.cdecl);

        foreach (param; parameters)
            func.createParameter(param);

        return func;
    }

    mciMemoryAllocate = createFunction("mci_memory_allocate", getPointerType(UInt8Type.instance),
                                       [NativeUIntType.instance]);
    mciMemoryZeroAllocate = createFunction("mci_memory_zero_allocate", getPointerType(UInt8Type.instance),
                                           [NativeUIntType.instance,
                                            NativeUIntType.instance]);
    mciMemoryReallocate = createFunction("mci_memory_reallocate", getPointerType(UInt8Type.instance),
                                         [getPointerType(UInt8Type.instance),
                                          NativeUIntType.instance]);
    mciMemoryFree = createFunction("mci_memory_free", UnitType.instance,
                                   [getPointerType(UInt8Type.instance)]);

    mciGetStdIn = createFunction("mci_get_stdin", getPointerType(UInt8Type.instance));
    mciGetStdErr = createFunction("mci_get_stderr", getPointerType(UInt8Type.instance));
    mciGetStdOut = createFunction("mci_get_stdout", getPointerType(UInt8Type.instance));
    mciFileOpen = createFunction("mci_file_open", getPointerType(UInt8Type.instance),
                                 [getPointerType(UInt8Type.instance),
                                  NativeUIntType.instance,
                                  UInt8Type.instance,
                                  UInt8Type.instance]);
    mciFileClose = createFunction("mci_file_close", UnitType.instance,
                                  [getPointerType(UInt8Type.instance)]);
    mciFileFP = createFunction("mci_file_fp", getPointerType(UInt8Type.instance),
                               [getPointerType(UInt8Type.instance)]);
    mciFileEOF = createFunction("mci_file_eof", UInt8Type.instance,
                                [getPointerType(UInt8Type.instance)]);
    mciFileIsOpen = createFunction("mci_file_is_open", UInt8Type.instance,
                                   [getPointerType(UInt8Type.instance)]);
    mciFilePosition = createFunction("mci_file_position", UInt64Type.instance,
                                     [getPointerType(UInt8Type.instance)]);
    mciFileWrite = createFunction("mci_file_write", UnitType.instance,
                                  [getPointerType(UInt8Type.instance),
                                   getPointerType(UInt8Type.instance),
                                   NativeUIntType.instance]);
    mciFileWriteLine = createFunction("mci_file_write_line", UnitType.instance,
                                      [getPointerType(UInt8Type.instance),
                                       getPointerType(UInt8Type.instance),
                                       NativeUIntType.instance]);
    mciFileRead = createFunction("mci_file_read", getPointerType(UInt8Type.instance),
                                 [getPointerType(UInt8Type.instance),
                                  NativeUIntType.instance,
                                  getPointerType(NativeUIntType.instance)]);
    mciFileReadLine = createFunction("mci_file_read_line", getPointerType(UInt8Type.instance),
                                     [getPointerType(UInt8Type.instance),
                                      getPointerType(NativeUIntType.instance)]);
}
