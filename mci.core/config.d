module mci.core.config;

// This file figures out what kind of environment we're running
// in and sets appropriate constants. Reliance on these constants
// should, however, be avoided if possible.

pragma(msg, "------------------------------------------------------------");
pragma(msg, "Managed Compiler Infrastructure configuration information:");

version (D_NET)
{
    // We cannot run on D.NET because some things like signals
    // will interfere with the managed runtime.
    static assert(false, "D.NET is not supported.");
}

version (D_Version2)
{
    pragma(msg, "- Language: D 2.0");
}
else
{
    pragma(msg, "- Language: D 1.0");
}

version (DigitalMars)
{
    pragma(msg, "- Compiler: Digital Mars D (DMD)");
    
    public static immutable bool isDMD = true;
    public static immutable bool isGDC = false;
    public static immutable bool isLDC = false;
}
else version (GNU)
{
    pragma(msg, "- Compiler: GNU D Compiler (GDC)");
    
    public static immutable bool isDMD = false;
    public static immutable bool isGDC = true;
    public static immutable bool isLDC = false;
}
else version (LDC)
{
    pragma(msg, "- Compiler: LLVM D Compiler (LDC)");
    
    public static immutable bool isDMD = false;
    public static immutable bool isGDC = false;
    public static immutable bool isLDC = true;
}
else
{
    pragma(msg, "- Compiler: Unknown");
    
    public static immutable bool isDMD = false;
    public static immutable bool isGDC = false;
    public static immutable bool isLDC = false;
}

version (X86)
{
    pragma(msg, "- Architecture: x86");
    
    public static immutable bool is32Bit = true;
    public static immutable bool is64Bit = false;
}
else version (X86_64)
{
    pragma(msg, "- Architecture: x86-64");
    
    public static immutable bool is32Bit = false;
    public static immutable bool is64Bit = true;
}
else
{
    static assert(false, "Processor architecture could not be determined.");
}

version (LittleEndian)
{
    pragma(msg, "- Byte Order: Little Endian (LE)");
    
    public static immutable bool isLittleEndian = true;
    public static immutable bool isBigEndian = false;
}
else version (BigEndian)
{
    pragma(msg, "- Byte Order: Big Endian (BE)");
    
    public static immutable bool isLittleEndian = false;
    public static immutable bool isBigEndian = true;
}
else
{
    static assert(false, "Endianness could not be determined.");
}

version (D_InlineAsm_X86_64)
{
    pragma(msg, "- Inline Assembly: x86-64 & x86");
    
    public static immutable bool hasAsm = true;
    public static immutable bool hasX86Asm = true;
    public static immutable bool hasX64Asm = true;
}
else version (D_InlineAsm_X86)
{
    pragma(msg, "- Inline Assembly: x86");
    
    public static immutable bool hasAsm = true;
    public static immutable bool hasX86Asm = true;
    public static immutable bool hasX64Asm = false;
}
else
{
    pragma(msg, "- Inline Assembly: None");
    
    public static immutable bool hasAsm = false;
    public static immutable bool hasX86Asm = false;
    public static immutable bool hasX64Asm = false;
}

version (Windows)
{
    version (Win32)
    {
        pragma(msg, "- Operating System: Windows (32-bit)");
    }
    else version (Win64)
    {
        pragma(msg, "- Operating System: Windows (64-bit)");
    }
    else
    {
        static assert(false, "Unknown Windows bitness.");
    }
    
    public static immutable bool isWindows = true;
    public static immutable bool isPosix = false;
}
else version (Posix)
{
    version (FreeBSD)
    {
        pragma(msg, "- Operating System: FreeBSD");
    }
    else version (Solaris)
    {
        pragma(msg, "- Operating System: Solaris");
    }
    else version (OSX)
    {
        pragma(msg, "- Operating System: OS X");
    }
    else version (linux)
    {
        pragma(msg, "- Operating System: Linux");
    }
    else
    {
        static assert(false, "Unknown Posix operating system.");
    }
    
    public static immutable bool isWindows = false;
    public static immutable bool isPosix = true;
}
else
{
    static assert(false, "Operating system could not be determined.");
}

pragma(msg, "------------------------------------------------------------");
