module mci.vm.intrinsics.declarations;

import mci.core.common,
       mci.core.container,
       mci.core.code.functions,
       mci.core.code.modules,
       mci.core.typing.cache,
       mci.core.typing.core,
       mci.core.typing.types,
       mci.vm.intrinsics.atomic,
       mci.vm.intrinsics.config,
       mci.vm.intrinsics.math,
       mci.vm.intrinsics.memory;

public __gshared Module intrinsicModule;
public __gshared Lookup!(Function, function_t) intrinsicFunctions;

public __gshared
{
    Function mciGetCompiler;
    Function mciGetArchitecture;
    Function mciGetOperatingSystem;
    Function mciGetEndianness;
    Function mciIs32Bit;

    Function mciAtomicExchangeU;
    Function mciAtomicAddU;
    Function mciAtomicSubU;
    Function mciAtomicMulU;
    Function mciAtomicDivU;
    Function mciAtomicRemU;
    Function mciAtomicAndU;
    Function mciAtomicOrU;
    Function mciAtomicXOrU;
    Function mciAtomicExchangeS;
    Function mciAtomicAddS;
    Function mciAtomicSubS;
    Function mciAtomicMulS;
    Function mciAtomicDivS;
    Function mciAtomicRemS;
    Function mciAtomicAndS;
    Function mciAtomicOrS;
    Function mciAtomicXOrS;

    Function mciIsAligned;
    Function mciGCCollect;
    Function mciGCMinimize;
    Function mciGCGetCollections;
    Function mciGCAddPressure;
    Function mciGCRemovePressure;
    Function mciGCIsGenerational;
    Function mciGCGetGenerations;
    Function mciGCGenerationCollect;
    Function mciGCGenerationMinimize;
    Function mciGCGenerationGetCollections;
    Function mciGCIsInteractive;
    Function mciGCAddAllocateCallback;
    Function mciGCAddFreeCallback;
    Function mciGCIsAtomic;
    Function mciGCGetBarriers;

    Function mciNANPayloadF32;
    Function mciNANPayloadF64;
    Function mciIsNANF32;
    Function mciIsNANF64;
    Function mciIsInfF32;
    Function mciIsInfF64;

    StructureType objectType;
}

public enum string intrinsicModuleName = "mci";

template createFunction(alias function_)
{
    Function createFunction(Type returnType, Type[] parameters ...)
    out (result)
    {
        assert(result);
    }
    body
    {
        auto f = new Function(intrinsicModule, __traits(identifier, function_), returnType, CallingConvention.cdecl, FunctionAttributes.intrinsic);

        foreach (param; parameters)
            f.createParameter(param);

        f.close();

        (cast(NoNullDictionary!(Function, function_t))intrinsicFunctions)[f] = cast(function_t)&function_;

        return f;
    }
}

shared static this()
{
    intrinsicModule = new typeof(intrinsicModule)(intrinsicModuleName);
    intrinsicFunctions = new NoNullDictionary!(Function, function_t)();

    objectType = new StructureType(intrinsicModule, "Object");
    objectType.close();

    mciGetCompiler = createFunction!mci_get_compiler(UInt8Type.instance);
    mciGetArchitecture = createFunction!mci_get_architecture(UInt8Type.instance);
    mciGetOperatingSystem = createFunction!mci_get_operating_system(UInt8Type.instance);
    mciGetEndianness = createFunction!mci_get_endianness(UInt8Type.instance);
    mciIs32Bit = createFunction!mci_is_32_bit(NativeUIntType.instance);

    mciAtomicExchangeU = createFunction!mci_atomic_exchange_u(NativeUIntType.instance,
                                                              getPointerType(NativeUIntType.instance),
                                                              NativeUIntType.instance,
                                                              NativeUIntType.instance);
    mciAtomicAddU = createFunction!mci_atomic_add_u(NativeUIntType.instance,
                                                    getPointerType(NativeUIntType.instance),
                                                    NativeUIntType.instance);
    mciAtomicSubU = createFunction!mci_atomic_sub_u(NativeUIntType.instance,
                                                    getPointerType(NativeUIntType.instance),
                                                    NativeUIntType.instance,
                                                    getPointerType(NativeUIntType.instance),
                                                    NativeUIntType.instance);
    mciAtomicMulU = createFunction!mci_atomic_mul_u(NativeUIntType.instance,
                                                    getPointerType(NativeUIntType.instance),
                                                    NativeUIntType.instance);
    mciAtomicDivU = createFunction!mci_atomic_div_u(NativeUIntType.instance,
                                                    getPointerType(NativeUIntType.instance),
                                                    NativeUIntType.instance);
    mciAtomicRemU = createFunction!mci_atomic_rem_u(NativeUIntType.instance,
                                                    getPointerType(NativeUIntType.instance),
                                                    NativeUIntType.instance);
    mciAtomicAndU = createFunction!mci_atomic_and_u(NativeUIntType.instance,
                                                    getPointerType(NativeUIntType.instance),
                                                    NativeUIntType.instance);
    mciAtomicOrU = createFunction!mci_atomic_or_u(NativeUIntType.instance,
                                                  getPointerType(NativeUIntType.instance),
                                                  NativeUIntType.instance);
    mciAtomicXOrU = createFunction!mci_atomic_xor_u(NativeUIntType.instance,
                                                    getPointerType(NativeUIntType.instance),
                                                    NativeUIntType.instance);
    mciAtomicExchangeS = createFunction!mci_atomic_exchange_s(NativeUIntType.instance,
                                                              getPointerType(NativeIntType.instance),
                                                              NativeIntType.instance,
                                                              NativeIntType.instance);
    mciAtomicAddS = createFunction!mci_atomic_add_s(NativeIntType.instance,
                                                    getPointerType(NativeIntType.instance),
                                                    NativeIntType.instance);
    mciAtomicSubS = createFunction!mci_atomic_sub_s(NativeIntType.instance,
                                                    getPointerType(NativeIntType.instance),
                                                    NativeIntType.instance);
    mciAtomicMulS = createFunction!mci_atomic_mul_s(NativeIntType.instance,
                                                    getPointerType(NativeIntType.instance),
                                                    NativeIntType.instance);
    mciAtomicDivS = createFunction!mci_atomic_div_s(NativeIntType.instance,
                                                    getPointerType(NativeIntType.instance),
                                                    NativeIntType.instance);
    mciAtomicRemS = createFunction!mci_atomic_rem_s(NativeIntType.instance,
                                                    getPointerType(NativeIntType.instance),
                                                    NativeIntType.instance);
    mciAtomicAndS = createFunction!mci_atomic_and_s(NativeIntType.instance,
                                                    getPointerType(NativeIntType.instance),
                                                    NativeIntType.instance);
    mciAtomicOrS = createFunction!mci_atomic_or_s(NativeIntType.instance,
                                                  getPointerType(NativeIntType.instance),
                                                  NativeIntType.instance);
    mciAtomicXOrS = createFunction!mci_atomic_xor_s(NativeIntType.instance,
                                                    getPointerType(NativeIntType.instance),
                                                    NativeIntType.instance);

    mciIsAligned = createFunction!mci_is_aligned(NativeUIntType.instance,
                                                 getPointerType(UInt8Type.instance));
    mciGCCollect = createFunction!mci_gc_collect(null);
    mciGCMinimize = createFunction!mci_gc_minimize(null);
    mciGCGetCollections = createFunction!mci_gc_get_collections(UInt64Type.instance);
    mciGCAddPressure = createFunction!mci_gc_add_pressure(null,
                                                          NativeUIntType.instance);
    mciGCRemovePressure = createFunction!mci_gc_remove_pressure(null,
                                                                NativeUIntType.instance);
    mciGCIsGenerational = createFunction!mci_gc_is_generational(NativeUIntType.instance);
    mciGCGetGenerations = createFunction!mci_gc_get_generations(NativeUIntType.instance);
    mciGCGenerationCollect = createFunction!mci_gc_generation_collect(null,
                                                                      NativeUIntType.instance);
    mciGCGenerationMinimize = createFunction!mci_gc_generation_minimize(null,
                                                                        NativeUIntType.instance);
    mciGCGenerationGetCollections = createFunction!mci_gc_generation_get_collections(UInt64Type.instance,
                                                                                     NativeUIntType.instance);
    mciGCIsInteractive = createFunction!mci_gc_is_interactive(NativeUIntType.instance);
    mciGCAddAllocateCallback = createFunction!mci_gc_add_allocate_callback(null,
                                                                           getFunctionPointerType(CallingConvention.cdecl,
                                                                                                  null,
                                                                                                  new NoNullList!Type(toIterable!Type(objectType))));
    mciGCAddFreeCallback = createFunction!mci_gc_add_free_callback(null,
                                                                   getFunctionPointerType(CallingConvention.cdecl,
                                                                                          null,
                                                                                          new NoNullList!Type(toIterable!Type(objectType))));
    mciGCIsAtomic = createFunction!mci_gc_is_atomic(NativeUIntType.instance);
    mciGCGetBarriers = createFunction!mci_gc_get_barriers(UInt8Type.instance);

    mciNANPayloadF32 = createFunction!mci_nan_payload_f32(Float32Type.instance,
                                                          UInt32Type.instance);
    mciNANPayloadF64 = createFunction!mci_nan_payload_f64(Float64Type.instance,
                                                          UInt64Type.instance);
    mciIsNANF32 = createFunction!mci_is_nan_f32(Float32Type.instance,
                                                NativeUIntType.instance);
    mciIsNANF64 = createFunction!mci_is_nan_f64(Float64Type.instance,
                                                NativeUIntType.instance);
    mciIsInfF32 = createFunction!mci_is_inf_f32(Float32Type.instance,
                                                NativeUIntType.instance);
    mciIsInfF64 = createFunction!mci_is_inf_f64(Float64Type.instance,
                                                NativeUIntType.instance);
}
