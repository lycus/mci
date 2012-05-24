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
       mci.vm.intrinsics.memory,
       mci.vm.intrinsics.weak;

public __gshared Module intrinsicModule;
public __gshared Lookup!(Function, function_t) intrinsicFunctions;

public __gshared
{
    Function getCompiler;
    Function getArchitecture;
    Function getOperatingSystem;
    Function getEndianness;
    Function is32Bit;

    Function atomicLoad;
    Function atomicStore;
    Function atomicExchange;
    Function atomicLoadU;
    Function atomicStoreU;
    Function atomicExchangeU;
    Function atomicAddU;
    Function atomicSubU;
    Function atomicMulU;
    Function atomicDivU;
    Function atomicRemU;
    Function atomicAndU;
    Function atomicOrU;
    Function atomicXOrU;
    Function atomicLoadS;
    Function atomicStoreS;
    Function atomicExchangeS;
    Function atomicAddS;
    Function atomicSubS;
    Function atomicMulS;
    Function atomicDivS;
    Function atomicRemS;
    Function atomicAndS;
    Function atomicOrS;
    Function atomicXOrS;

    Function isAligned;
    Function gcCollect;
    Function gcMinimize;
    Function gcGetCollections;
    Function gcAddPressure;
    Function gcRemovePressure;
    Function gcIsGenerational;
    Function gcGetGenerations;
    Function gcGenerationCollect;
    Function gcGenerationMinimize;
    Function gcGenerationGetCollections;
    Function gcIsInteractive;
    Function gcAddAllocateCallback;
    Function gcRemoveAllocateCallback;
    Function gcSetFreeCallback;
    Function gcWaitForFreeCallbacks;
    Function gcIsAtomic;
    Function gcGetBarriers;

    Function nanWithPayloadF32;
    Function nanWithPayloadF64;
    Function nanGetPayloadF32;
    Function nanGetPayloadF64;
    Function isNANF32;
    Function isNANF64;
    Function isInfF32;
    Function isInfF64;

    Function createWeak;
    Function getWeakTarget;
    Function setWeakTarget;

    StructureType objectType;
    StructureType weakType;
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

    objectType = new typeof(objectType)(intrinsicModule, "Object");
    objectType.close();

    weakType = new typeof(weakType)(intrinsicModule, "Weak");
    weakType.createField("value", getReferenceType(objectType));
    weakType.close();

    getCompiler = createFunction!get_compiler(UInt8Type.instance);
    getArchitecture = createFunction!get_architecture(UInt8Type.instance);
    getOperatingSystem = createFunction!get_operating_system(UInt8Type.instance);
    getEndianness = createFunction!get_endianness(UInt8Type.instance);
    is32Bit = createFunction!is_32_bit(NativeUIntType.instance);

    atomicLoad = createFunction!atomic_load(getReferenceType(objectType),
                                            getPointerType(getReferenceType(objectType)));
    atomicStore = createFunction!atomic_store(null,
                                              getPointerType(getReferenceType(objectType)),
                                              getReferenceType(objectType));
    atomicExchange = createFunction!atomic_exchange(NativeUIntType.instance,
                                                    getPointerType(getReferenceType(objectType)),
                                                    getReferenceType(objectType),
                                                    getReferenceType(objectType));
    atomicLoadU = createFunction!atomic_load_u(NativeUIntType.instance,
                                               getPointerType(NativeUIntType.instance));
    atomicStoreU = createFunction!atomic_store_u(null,
                                                 getPointerType(NativeUIntType.instance),
                                                 NativeUIntType.instance);
    atomicExchangeU = createFunction!atomic_exchange_u(NativeUIntType.instance,
                                                       getPointerType(NativeUIntType.instance),
                                                       NativeUIntType.instance,
                                                       NativeUIntType.instance);
    atomicAddU = createFunction!atomic_add_u(NativeUIntType.instance,
                                             getPointerType(NativeUIntType.instance),
                                             NativeUIntType.instance);
    atomicSubU = createFunction!atomic_sub_u(NativeUIntType.instance,
                                             getPointerType(NativeUIntType.instance),
                                             NativeUIntType.instance,
                                             getPointerType(NativeUIntType.instance),
                                             NativeUIntType.instance);
    atomicMulU = createFunction!atomic_mul_u(NativeUIntType.instance,
                                             getPointerType(NativeUIntType.instance),
                                             NativeUIntType.instance);
    atomicDivU = createFunction!atomic_div_u(NativeUIntType.instance,
                                             getPointerType(NativeUIntType.instance),
                                             NativeUIntType.instance);
    atomicRemU = createFunction!atomic_rem_u(NativeUIntType.instance,
                                             getPointerType(NativeUIntType.instance),
                                             NativeUIntType.instance);
    atomicAndU = createFunction!atomic_and_u(NativeUIntType.instance,
                                             getPointerType(NativeUIntType.instance),
                                             NativeUIntType.instance);
    atomicOrU = createFunction!atomic_or_u(NativeUIntType.instance,
                                           getPointerType(NativeUIntType.instance),
                                           NativeUIntType.instance);
    atomicXOrU = createFunction!atomic_xor_u(NativeUIntType.instance,
                                             getPointerType(NativeUIntType.instance),
                                             NativeUIntType.instance);
    atomicLoadS = createFunction!atomic_load_s(NativeIntType.instance,
                                               getPointerType(NativeIntType.instance));
    atomicStoreS = createFunction!atomic_store_s(null,
                                                 getPointerType(NativeIntType.instance),
                                                 NativeIntType.instance);
    atomicExchangeS = createFunction!atomic_exchange_s(NativeIntType.instance,
                                                       getPointerType(NativeIntType.instance),
                                                       NativeIntType.instance,
                                                       NativeIntType.instance);
    atomicAddS = createFunction!atomic_add_s(NativeIntType.instance,
                                             getPointerType(NativeIntType.instance),
                                             NativeIntType.instance);
    atomicSubS = createFunction!atomic_sub_s(NativeIntType.instance,
                                             getPointerType(NativeIntType.instance),
                                             NativeIntType.instance);
    atomicMulS = createFunction!atomic_mul_s(NativeIntType.instance,
                                             getPointerType(NativeIntType.instance),
                                             NativeIntType.instance);
    atomicDivS = createFunction!atomic_div_s(NativeIntType.instance,
                                             getPointerType(NativeIntType.instance),
                                             NativeIntType.instance);
    atomicRemS = createFunction!atomic_rem_s(NativeIntType.instance,
                                             getPointerType(NativeIntType.instance),
                                             NativeIntType.instance);
    atomicAndS = createFunction!atomic_and_s(NativeIntType.instance,
                                             getPointerType(NativeIntType.instance),
                                             NativeIntType.instance);
    atomicOrS = createFunction!atomic_or_s(NativeIntType.instance,
                                           getPointerType(NativeIntType.instance),
                                           NativeIntType.instance);
    atomicXOrS = createFunction!atomic_xor_s(NativeIntType.instance,
                                             getPointerType(NativeIntType.instance),
                                             NativeIntType.instance);

    isAligned = createFunction!is_aligned(NativeUIntType.instance,
                                          getPointerType(UInt8Type.instance));
    gcCollect = createFunction!gc_collect_(null);
    gcMinimize = createFunction!gc_minimize_(null);
    gcGetCollections = createFunction!gc_get_collections(UInt64Type.instance);
    gcAddPressure = createFunction!gc_add_pressure(null,
                                                   NativeUIntType.instance);
    gcRemovePressure = createFunction!gc_remove_pressure(null,
                                                         NativeUIntType.instance);
    gcIsGenerational = createFunction!gc_is_generational(NativeUIntType.instance);
    gcGetGenerations = createFunction!gc_get_generations(NativeUIntType.instance);
    gcGenerationCollect = createFunction!gc_generation_collect(null,
                                                               NativeUIntType.instance);
    gcGenerationMinimize = createFunction!gc_generation_minimize(null,
                                                                 NativeUIntType.instance);
    gcGenerationGetCollections = createFunction!gc_generation_get_collections(UInt64Type.instance,
                                                                              NativeUIntType.instance);
    gcIsInteractive = createFunction!gc_is_interactive(NativeUIntType.instance);
    gcAddAllocateCallback = createFunction!gc_add_allocate_callback(null,
                                                                    getFunctionPointerType(CallingConvention.cdecl, null,
                                                                                           toNoNullList(toIterable!Type(getReferenceType(objectType)))));
    gcRemoveAllocateCallback = createFunction!gc_remove_allocate_callback(null,
                                                                          getFunctionPointerType(CallingConvention.cdecl, null,
                                                                                                 toNoNullList(toIterable!Type(getReferenceType(objectType)))));
    gcSetFreeCallback = createFunction!gc_set_free_callback(null,
                                                            getReferenceType(objectType),
                                                            getFunctionPointerType(CallingConvention.cdecl, null,
                                                                                   toNoNullList(toIterable!Type(getReferenceType(objectType)))));
    gcWaitForFreeCallbacks = createFunction!gc_wait_for_free_callbacks(null);
    gcIsAtomic = createFunction!gc_is_atomic(NativeUIntType.instance);
    gcGetBarriers = createFunction!gc_get_barriers(UInt8Type.instance);

    nanWithPayloadF32 = createFunction!nan_with_payload_f32(Float32Type.instance,
                                                            UInt32Type.instance);
    nanWithPayloadF64 = createFunction!nan_with_payload_f64(Float64Type.instance,
                                                            UInt64Type.instance);
    nanGetPayloadF32 = createFunction!nan_get_payload_f32(UInt32Type.instance,
                                                          Float32Type.instance);
    nanGetPayloadF64 = createFunction!nan_get_payload_f64(UInt64Type.instance,
                                                          Float64Type.instance);
    isNANF32 = createFunction!is_nan_f32(NativeUIntType.instance,
                                         Float32Type.instance);
    isNANF64 = createFunction!is_nan_f64(NativeUIntType.instance,
                                         Float64Type.instance);
    isInfF32 = createFunction!is_inf_f32(NativeUIntType.instance,
                                         Float32Type.instance);
    isInfF64 = createFunction!is_inf_f64(NativeUIntType.instance,
                                         Float64Type.instance);

    createWeak = createFunction!create_weak(getReferenceType(weakType),
                                            getReferenceType(objectType));
    getWeakTarget = createFunction!get_weak_target(getReferenceType(objectType),
                                                   getReferenceType(weakType));
    setWeakTarget = createFunction!set_weak_target(null,
                                                   getReferenceType(weakType),
                                                   getReferenceType(objectType));
}
