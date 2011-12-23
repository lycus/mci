module mci.vm.io.common;

public enum string fileMagic = "LAIC"; // Reverse of CIAL (Compiled Intermediate Assembly Language).

public enum uint fileVersion = 16;

public enum TypeReferenceType : ubyte
{
    core = 0,
    structure = 1,
    pointer = 2,
    array = 3,
    vector = 4,
    function_ = 5,
}

public enum CoreTypeIdentifier : ubyte
{
    int8 = 0,
    uint8 = 1,
    int16 = 2,
    uint16 = 3,
    int32 = 4,
    uint32 = 5,
    int64 = 6,
    uint64 = 7,
    int_ = 8,
    uint_ = 9,
    float32 = 10,
    float64 = 11,
}
