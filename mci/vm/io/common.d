module mci.vm.io.common;

public enum string fileMagic = "LAIC"; // Reverse of CIAL (Compiled Intermediate Assembly Language).

public enum uint fileVersion = 2;

public enum TypeReferenceType : ubyte
{
    core = 0,
    structure = 1,
    pointer = 2,
    function_ = 3,
}

public enum CoreTypeIdentifier : ubyte
{
    unit = 0,
    int8 = 1,
    uint8 = 2,
    int16 = 3,
    uint16 = 4,
    int32 = 5,
    uint32 = 6,
    int64 = 7,
    uint64 = 8,
    int_ = 9,
    uint_ = 10,
    float32 = 11,
    float64 = 12,
}
