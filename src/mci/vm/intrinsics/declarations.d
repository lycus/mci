module mci.vm.intrinsics.declarations;

import std.algorithm,
       std.traits,
       mci.core.common,
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

public __gshared Module intrinsicModule; /// The module that all intrinsics are attached to.
public __gshared Lookup!(Function, function_t) intrinsicFunctions; /// A name to pointer mapping of all intrinsics.

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

private enum string intrinsicFunctionPrefix = "mci_";

private Function createFunction(alias function_)(Type returnType, Type[] parameters ...)
in
{
    static assert(startsWith(__traits(identifier, function_), intrinsicFunctionPrefix));
    static assert(__traits(identifier, function_).length > intrinsicFunctionPrefix.length);

    alias ParameterTypeTuple!function_ P;

    static assert(P.length);

    assert(parameters.length == P.length - 1);

    foreach (param; parameters)
        assert(param);
}
out (result)
{
    assert(result);
}
body
{
    auto ident = __traits(identifier, function_)[intrinsicFunctionPrefix.length .. $];
    auto f = new Function(intrinsicModule, ident, returnType, CallingConvention.cdecl, FunctionAttributes.intrinsic);

    foreach (param; parameters)
        f.createParameter(param);

    f.close();

    (cast(NoNullDictionary!(Function, function_t, false))intrinsicFunctions)[f] = cast(function_t)&function_;

    return f;
}

shared static this()
{
    intrinsicModule = new typeof(intrinsicModule)("mci");
    intrinsicFunctions = new NoNullDictionary!(Function, function_t, false)();

    objectType = new typeof(objectType)(intrinsicModule, "Object");
    objectType.close();

    weakType = new typeof(weakType)(intrinsicModule, "Weak");
    weakType.createField("value", getReferenceType(objectType));
    weakType.close();

    getCompiler = createFunction!mci_get_compiler(UInt8Type.instance);
    getArchitecture = createFunction!mci_get_architecture(UInt8Type.instance);
    getOperatingSystem = createFunction!mci_get_operating_system(UInt8Type.instance);
    getEndianness = createFunction!mci_get_endianness(UInt8Type.instance);
    is32Bit = createFunction!mci_is_32_bit(NativeUIntType.instance);

    atomicLoad = createFunction!mci_atomic_load(getReferenceType(objectType),
                                                getPointerType(getReferenceType(objectType)));
    atomicStore = createFunction!mci_atomic_store(null,
                                                  getPointerType(getReferenceType(objectType)),
                                                  getReferenceType(objectType));
    atomicExchange = createFunction!mci_atomic_exchange(NativeUIntType.instance,
                                                        getPointerType(getReferenceType(objectType)),
                                                        getReferenceType(objectType),
                                                        getReferenceType(objectType));
    atomicLoadU = createFunction!mci_atomic_load_u(NativeUIntType.instance,
                                                   getPointerType(NativeUIntType.instance));
    atomicStoreU = createFunction!mci_atomic_store_u(null,
                                                     getPointerType(NativeUIntType.instance),
                                                     NativeUIntType.instance);
    atomicExchangeU = createFunction!mci_atomic_exchange_u(NativeUIntType.instance,
                                                           getPointerType(NativeUIntType.instance),
                                                           NativeUIntType.instance,
                                                           NativeUIntType.instance);
    atomicAddU = createFunction!mci_atomic_add_u(NativeUIntType.instance,
                                                 getPointerType(NativeUIntType.instance),
                                                 NativeUIntType.instance);
    atomicSubU = createFunction!mci_atomic_sub_u(NativeUIntType.instance,
                                                 getPointerType(NativeUIntType.instance),
                                                 NativeUIntType.instance);
    atomicMulU = createFunction!mci_atomic_mul_u(NativeUIntType.instance,
                                                 getPointerType(NativeUIntType.instance),
                                                 NativeUIntType.instance);
    atomicDivU = createFunction!mci_atomic_div_u(NativeUIntType.instance,
                                                 getPointerType(NativeUIntType.instance),
                                                 NativeUIntType.instance);
    atomicRemU = createFunction!mci_atomic_rem_u(NativeUIntType.instance,
                                                 getPointerType(NativeUIntType.instance),
                                                 NativeUIntType.instance);
    atomicAndU = createFunction!mci_atomic_and_u(NativeUIntType.instance,
                                                 getPointerType(NativeUIntType.instance),
                                                 NativeUIntType.instance);
    atomicOrU = createFunction!mci_atomic_or_u(NativeUIntType.instance,
                                               getPointerType(NativeUIntType.instance),
                                               NativeUIntType.instance);
    atomicXOrU = createFunction!mci_atomic_xor_u(NativeUIntType.instance,
                                                 getPointerType(NativeUIntType.instance),
                                                 NativeUIntType.instance);
    atomicLoadS = createFunction!mci_atomic_load_s(NativeIntType.instance,
                                                   getPointerType(NativeIntType.instance));
    atomicStoreS = createFunction!mci_atomic_store_s(null,
                                                     getPointerType(NativeIntType.instance),
                                                     NativeIntType.instance);
    atomicExchangeS = createFunction!mci_atomic_exchange_s(NativeIntType.instance,
                                                           getPointerType(NativeIntType.instance),
                                                           NativeIntType.instance,
                                                           NativeIntType.instance);
    atomicAddS = createFunction!mci_atomic_add_s(NativeIntType.instance,
                                                 getPointerType(NativeIntType.instance),
                                                 NativeIntType.instance);
    atomicSubS = createFunction!mci_atomic_sub_s(NativeIntType.instance,
                                                 getPointerType(NativeIntType.instance),
                                                 NativeIntType.instance);
    atomicMulS = createFunction!mci_atomic_mul_s(NativeIntType.instance,
                                                 getPointerType(NativeIntType.instance),
                                                 NativeIntType.instance);
    atomicDivS = createFunction!mci_atomic_div_s(NativeIntType.instance,
                                                 getPointerType(NativeIntType.instance),
                                                 NativeIntType.instance);
    atomicRemS = createFunction!mci_atomic_rem_s(NativeIntType.instance,
                                                 getPointerType(NativeIntType.instance),
                                                 NativeIntType.instance);
    atomicAndS = createFunction!mci_atomic_and_s(NativeIntType.instance,
                                                 getPointerType(NativeIntType.instance),
                                                 NativeIntType.instance);
    atomicOrS = createFunction!mci_atomic_or_s(NativeIntType.instance,
                                               getPointerType(NativeIntType.instance),
                                               NativeIntType.instance);
    atomicXOrS = createFunction!mci_atomic_xor_s(NativeIntType.instance,
                                                 getPointerType(NativeIntType.instance),
                                                 NativeIntType.instance);

    gcCollect = createFunction!mci_gc_collect(null);
    gcMinimize = createFunction!mci_gc_minimize(null);
    gcGetCollections = createFunction!mci_gc_get_collections(UInt64Type.instance);
    gcAddPressure = createFunction!mci_gc_add_pressure(null,
                                                       NativeUIntType.instance);
    gcRemovePressure = createFunction!mci_gc_remove_pressure(null,
                                                             NativeUIntType.instance);
    gcIsGenerational = createFunction!mci_gc_is_generational(NativeUIntType.instance);
    gcGetGenerations = createFunction!mci_gc_get_generations(NativeUIntType.instance);
    gcGenerationCollect = createFunction!mci_gc_generation_collect(null,
                                                                   NativeUIntType.instance);
    gcGenerationMinimize = createFunction!mci_gc_generation_minimize(null,
                                                                     NativeUIntType.instance);
    gcGenerationGetCollections = createFunction!mci_gc_generation_get_collections(UInt64Type.instance,
                                                                                  NativeUIntType.instance);
    gcIsInteractive = createFunction!mci_gc_is_interactive(NativeUIntType.instance);
    gcAddAllocateCallback = createFunction!mci_gc_add_allocate_callback(null,
                                                                        getFunctionPointerType(CallingConvention.cdecl, null,
                                                                                               toNoNullList(toIterable!Type(getReferenceType(objectType)))));
    gcRemoveAllocateCallback = createFunction!mci_gc_remove_allocate_callback(null,
                                                                              getFunctionPointerType(CallingConvention.cdecl, null,
                                                                                                     toNoNullList(toIterable!Type(getReferenceType(objectType)))));
    gcSetFreeCallback = createFunction!mci_gc_set_free_callback(null,
                                                                getReferenceType(objectType),
                                                                getFunctionPointerType(CallingConvention.cdecl, null,
                                                                                       toNoNullList(toIterable!Type(getReferenceType(objectType)))));
    gcWaitForFreeCallbacks = createFunction!mci_gc_wait_for_free_callbacks(null);
    gcIsAtomic = createFunction!mci_gc_is_atomic(NativeUIntType.instance);
    gcGetBarriers = createFunction!mci_gc_get_barriers(UInt8Type.instance);

    nanWithPayloadF32 = createFunction!mci_nan_with_payload_f32(Float32Type.instance,
                                                                UInt32Type.instance);
    nanWithPayloadF64 = createFunction!mci_nan_with_payload_f64(Float64Type.instance,
                                                                UInt64Type.instance);
    nanGetPayloadF32 = createFunction!mci_nan_get_payload_f32(UInt32Type.instance,
                                                              Float32Type.instance);
    nanGetPayloadF64 = createFunction!mci_nan_get_payload_f64(UInt64Type.instance,
                                                              Float64Type.instance);
    isNANF32 = createFunction!mci_is_nan_f32(NativeUIntType.instance,
                                             Float32Type.instance);
    isNANF64 = createFunction!mci_is_nan_f64(NativeUIntType.instance,
                                             Float64Type.instance);
    isInfF32 = createFunction!mci_is_inf_f32(NativeUIntType.instance,
                                             Float32Type.instance);
    isInfF64 = createFunction!mci_is_inf_f64(NativeUIntType.instance,
                                             Float64Type.instance);

    createWeak = createFunction!mci_create_weak(getReferenceType(weakType),
                                                getReferenceType(objectType));
    getWeakTarget = createFunction!mci_get_weak_target(getReferenceType(objectType),
                                                       getReferenceType(weakType));
    setWeakTarget = createFunction!mci_set_weak_target(null,
                                                       getReferenceType(weakType),
                                                       getReferenceType(objectType));
}
