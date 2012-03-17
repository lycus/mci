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
    Function getCompiler;
    Function getArchitecture;
    Function getOperatingSystem;
    Function getEndianness;
    Function is32Bit;

    Function atomicExchangeU;
    Function atomicAddU;
    Function atomicSubU;
    Function atomicMulU;
    Function atomicDivU;
    Function atomicRemU;
    Function atomicAndU;
    Function atomicOrU;
    Function atomicXOrU;
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
    Function gcAddFreeCallback;
    Function gcIsAtomic;
    Function gcGetBarriers;

    Function nanPayloadF32;
    Function nanPayloadF64;
    Function isNANF32;
    Function isNANF64;
    Function isInfF32;
    Function isInfF64;

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

    getCompiler = createFunction!get_compiler(UInt8Type.instance);
    getArchitecture = createFunction!get_architecture(UInt8Type.instance);
    getOperatingSystem = createFunction!get_operating_system(UInt8Type.instance);
    getEndianness = createFunction!get_endianness(UInt8Type.instance);
    is32Bit = createFunction!is_32_bit(NativeUIntType.instance);

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
    atomicExchangeS = createFunction!atomic_exchange_s(NativeUIntType.instance,
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
    gcCollect = createFunction!gc_collect(null);
    gcMinimize = createFunction!gc_minimize(null);
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
                                                                                           toNoNullList(toIterable!Type(objectType))));
    gcAddFreeCallback = createFunction!gc_add_free_callback(null,
                                                            getFunctionPointerType(CallingConvention.cdecl, null,
                                                                                   toNoNullList(toIterable!Type(objectType))));
    gcIsAtomic = createFunction!gc_is_atomic(NativeUIntType.instance);
    gcGetBarriers = createFunction!gc_get_barriers(UInt8Type.instance);

    nanPayloadF32 = createFunction!nan_payload_f32(Float32Type.instance,
                                                   UInt32Type.instance);
    nanPayloadF64 = createFunction!nan_payload_f64(Float64Type.instance,
                                                   UInt64Type.instance);
    isNANF32 = createFunction!is_nan_f32(NativeUIntType.instance,
                                         Float32Type.instance);
    isNANF64 = createFunction!is_nan_f64(NativeUIntType.instance,
                                         Float64Type.instance);
    isInfF32 = createFunction!is_inf_f32(NativeUIntType.instance,
                                         Float32Type.instance);
    isInfF64 = createFunction!is_inf_f64(NativeUIntType.instance,
                                         Float64Type.instance);
}
