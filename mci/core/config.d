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
    static assert(false, "Unsupported D language version.");
}

version (DigitalMars)
{
    pragma(msg, "- Compiler: Digital Mars D (DMD)");

    public enum bool isDMD = true;
    public enum bool isGDC = false;
    public enum bool isLDC = false;
    public enum bool isSDC = false;
}
else version (GNU)
{
    pragma(msg, "- Compiler: GNU D Compiler (GDC)");

    public enum bool isDMD = false;
    public enum bool isGDC = true;
    public enum bool isLDC = false;
    public enum bool isSDC = false;
}
else version (LDC)
{
    pragma(msg, "- Compiler: LLVM D Compiler (LDC)");

    public enum bool isDMD = false;
    public enum bool isGDC = false;
    public enum bool isLDC = true;
    public enum bool isSDC = false;
}
else version (SDC)
{
    pragma(msg, "- Compiler: Stupid D Compiler (SDC)");

    public enum bool isDMD = false;
    public enum bool isGDC = false;
    public enum bool isLDC = false;
    public enum bool isSDC = true;
}
else
{
    pragma(msg, "- Compiler: Unknown");

    public enum bool isDMD = false;
    public enum bool isGDC = false;
    public enum bool isLDC = false;
    public enum bool isSDC = false;
}

version (X86)
{
    pragma(msg, "- Architecture: x86");

    public enum bool is32Bit = true;
    public enum bool is64Bit = false;
}
else version (X86_64)
{
    pragma(msg, "- Architecture: x86-64");

    public enum bool is32Bit = false;
    public enum bool is64Bit = true;
}
else
{
    static assert(false, "Processor architecture could not be determined.");
}

version (LittleEndian)
{
    pragma(msg, "- Byte Order: Little Endian (LE)");

    public enum bool isLittleEndian = true;
    public enum bool isBigEndian = false;
}
else version (BigEndian)
{
    pragma(msg, "- Byte Order: Big Endian (BE)");

    public enum bool isLittleEndian = false;
    public enum bool isBigEndian = true;
}
else
{
    static assert(false, "Endianness could not be determined.");
}

version (D_InlineAsm_X86_64)
{
    pragma(msg, "- Inline Assembly: x86-64 & x86");

    public enum bool hasAsm = true;
    public enum bool hasX86Asm = true;
    public enum bool hasX64Asm = true;
}
else version (D_InlineAsm_X86)
{
    pragma(msg, "- Inline Assembly: x86");

    public enum bool hasAsm = true;
    public enum bool hasX86Asm = true;
    public enum bool hasX64Asm = false;
}
else
{
    pragma(msg, "- Inline Assembly: None");

    public enum bool hasAsm = false;
    public enum bool hasX86Asm = false;
    public enum bool hasX64Asm = false;
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

    public enum bool isWindows = true;
    public enum bool isPosix = false;
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

    public enum bool isWindows = false;
    public enum bool isPosix = true;
}
else
{
    static assert(false, "Operating system could not be determined.");
}

pragma(msg, "------------------------------------------------------------");
