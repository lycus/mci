module mci.core.config;

import mci.core.common;

// This file figures out what kind of environment we're running
// in and sets appropriate constants. Reliance on these constants
// should be avoided if possible.

pragma(msg, "------------------------------------------------------------");
pragma(msg, "Managed Compiler Infrastructure configuration information:");

version (DigitalMars)
{
    pragma(msg, "- Compiler: Digital Mars D (DMD)");

    public enum Compiler compiler = Compiler.dmd;
}
else version (GNU)
{
    pragma(msg, "- Compiler: GNU D Compiler (GDC)");

    public enum Compiler compiler = Compiler.gdc;
}
else version (LDC)
{
    pragma(msg, "- Compiler: LLVM D Compiler (LDC)");

    public enum Compiler compiler = Compiler.ldc;
}
else version (SDC)
{
    pragma(msg, "- Compiler: Stupid D Compiler (SDC)");

    public enum Compiler compiler = Compiler.sdc;
}
else version (D_NET)
{
    // We cannot run on D.NET because some things like signals
    // will interfere with the managed runtime.
    static assert(false, "D.NET is not supported.");
}
else
{
    pragma(msg, "- Compiler: Unknown");

    public enum Compiler compiler = Compiler.unknown;
}

version (D_Version2)
{
    pragma(msg, "- Language: D 2.0");
}
else
{
    static assert(false, "Unsupported D language version.");
}

version (D_InlineAsm_X86_64)
{
    pragma(msg, "- Inline Assembly: x86-64");
}
else version (D_InlineAsm_X86)
{
    pragma(msg, "- Inline Assembly: x86");
}
else
{
    static assert(false, "Inline assembly not available.");
}

version (X86)
{
    pragma(msg, "- Architecture: x86 (32-bit)");

    public enum Architecture architecture = Architecture.x86;
}
else version (X86_64)
{
    pragma(msg, "- Architecture: x86 (64-bit)");

    public enum Architecture architecture = Architecture.x86;
}
else version (ARM)
{
    pragma(msg, "- Architecture: ARM (32-bit)");

    public enum Architecture architecture = Architecture.arm;
}
else version (PPC)
{
    pragma(msg, "- Architecture: PowerPC (32-bit)");

    public enum Architecture architecture = Architecture.ppc;
}
else version (PPC64)
{
    pragma(msg, "- Architecture: PowerPC (64-bit)");

    public enum Architecture architecture = Architecture.ppc;
}
else version (IA64)
{
    pragma(msg, "- Architecture: Itanium (64-bit)");

    public enum Architecture architecture = Architecture.ia64;
}
else version (MIPS)
{
    pragma(msg, "- Architecture: MIPS (32-bit)");

    public enum Architecture architecture = Architecture.mips;
}
else version (MIPS64)
{
    pragma(msg, "- Architecture: MIPS (64-bit)");

    public enum Architecture architecture = Architecture.mips;
}
else version (S390)
{
    static assert(false, "The System/390 architecture is not supported.");
}
else version (S390X)
{
    static assert(false, "The System/390 architecture is not supported.");
}
else version (SPARC)
{
    static assert(false, "The SPARC architecture is not supported.");
}
else version (SPARC64)
{
    static assert(false, "The SPARC architecture is not supported.");
}
else version (HPPA)
{
    static assert(false, "The PA-RISC architecture is not supported.");
}
else version (HPPA64)
{
    static assert(false, "The PA-RISC architecture is not supported.");
}
else version (SH)
{
    static assert(false, "The SuperH architecture is not supported.");
}
else version (SH64)
{
    static assert(false, "The SuperH architecture is not supported.");
}
else version (Alpha)
{
    static assert(false, "The Alpha architecture is not supported.");
}
else
{
    static assert(false, "Processor architecture could not be determined.");
}

version (D_LP64)
{
    pragma(msg, "- Pointer Length: 64-bit");

    public enum bool is32Bit = false;
}
else
{
    pragma(msg, "- Pointer Length: 32-bit");

    public enum bool is32Bit = true;
}

version (LittleEndian)
{
    pragma(msg, "- Byte Order: Little Endian (LE)");

    public enum Endianness endianness = Endianness.littleEndian;
}
else version (BigEndian)
{
    pragma(msg, "- Byte Order: Big Endian (BE)");

    public enum Endianness endianness = Endianness.bigEndian;
}
else
{
    static assert(false, "Endianness could not be determined.");
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
        static assert(false, "Unknown Windows bit width.");
    }

    public enum OperatingSystem operatingSystem = OperatingSystem.windows;
}
else version (Posix)
{
    version (FreeBSD)
    {
        pragma(msg, "- Operating System: FreeBSD");

        public enum OperatingSystem operatingSystem = OperatingSystem.freebsd;
    }
    else version (OpenBSD)
    {
        pragma(msg, "- Operating System: OpenBSD");

        public enum OperatingSystem operatingSystem = OperatingSystem.openbsd;
    }
    else version (BSD)
    {
        pragma(msg, "- Operating System: BSD");

        public enum OperatingSystem operatingSystem = OperatingSystem.bsd;
    }
    else version (AIX)
    {
        pragma(msg, "- Operating System: AIX");

        public enum OperatingSystem operatingSystem = OperatingSystem.aix;
    }
    else version (Solaris)
    {
        pragma(msg, "- Operating System: Solaris");

        public enum OperatingSystem operatingSystem = OperatingSystem.solaris;
    }
    else version (Hurd)
    {
        pragma(msg, "- Operating System: Hurd");

        public enum OperatingSystem operatingSystem = OperatingSystem.hurd;
    }
    else version (linux)
    {
        pragma(msg, "- Operating System: Linux");

        public enum OperatingSystem operatingSystem = OperatingSystem.linux;
    }
    else version (OSX)
    {
        pragma(msg, "- Operating System: OS X");

        public enum OperatingSystem operatingSystem = OperatingSystem.osx;
    }
    else version (SkyOS)
    {
        static assert(false, "SkyOS is not supported.");
    }
    else version (SysV3)
    {
        static assert(false, "System V R3 is not supported.");
    }
    else version (SysV4)
    {
        static assert(false, "System V R4 is not supported.");
    }
    else
    {
        static assert(false, "Unknown POSIX operating system.");
    }
}
else
{
    static assert(false, "Operating system could not be determined.");
}

version (Cygwin)
{
    pragma(msg, "- Emulation Layer: Cygwin");

    public enum EmulationLayer emulationLayer = EmulationLayer.cygwin;
}
else version (MinGW)
{
    pragma(msg, "- Emulation Layer: MinGW");

    public enum EmulationLayer emulationLayer = EmulationLayer.mingw;
}
else
{
    pragma(msg, "- Emulation Layer: None");

    public enum EmulationLayer emulationLayer = EmulationLayer.none;
}

pragma(msg, "------------------------------------------------------------");
