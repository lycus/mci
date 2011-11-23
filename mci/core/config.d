module mci.core.config;

import mci.core.common;

// This file figures out what kind of environment we're running
// in and sets appropriate constants. Reliance on these constants
// should be avoided if possible.

version (DigitalMars)
{
    public enum Compiler compiler = Compiler.dmd;
    public enum string compilerName = "DMD";
}
else version (GNU)
{
    public enum Compiler compiler = Compiler.gdc;
    public enum string compilerName = "GDC";
}
else version (LDC)
{
    public enum Compiler compiler = Compiler.ldc;
    public enum string compilerName = "LDC";
}
else version (SDC)
{
    public enum Compiler compiler = Compiler.sdc;
    public enum string compilerName = "SDC";
}
else version (D_NET)
{
    // We cannot run on D.NET because some things like signals
    // will interfere with the managed runtime.
    static assert(false, "D.NET is not supported.");
}
else
{
    static assert(false, "Compiler could not be determined.");
}

version (D_Version2)
{
}
else
{
    static assert(false, "Unsupported D language version.");
}

version (D_InlineAsm_X86_64)
{
}
else version (D_InlineAsm_X86)
{
}
else
{
    static assert(false, "Inline assembly not available.");
}

version (X86)
{
    public enum Architecture architecture = Architecture.x86;
    public enum string architectureName = "x86";
}
else version (X86_64)
{
    public enum Architecture architecture = Architecture.x86;
    public enum string architectureName = "x86";
}
else version (ARM)
{
    public enum Architecture architecture = Architecture.arm;
    public enum string architectureName = "ARM";
}
else version (PPC)
{
    public enum Architecture architecture = Architecture.ppc;
    public enum string architectureName = "PowerPC";
}
else version (PPC64)
{
    public enum Architecture architecture = Architecture.ppc;
    public enum string architectureName = "PowerPC";
}
else version (IA64)
{
    public enum Architecture architecture = Architecture.ia64;
    public enum string architectureName = "Itanium";
}
else version (MIPS)
{
    public enum Architecture architecture = Architecture.mips;
    public enum string architectureName = "MIPS";
}
else version (MIPS64)
{
    public enum Architecture architecture = Architecture.mips;
    public enum string architectureName = "MIPS";
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
    public enum bool is32Bit = false;
}
else
{
    public enum bool is32Bit = true;
}

version (LittleEndian)
{
    public enum Endianness endianness = Endianness.littleEndian;
    public string endiannessName = "Little Endian (LE)";
}
else version (BigEndian)
{
    public enum Endianness endianness = Endianness.bigEndian;
    public string endiannessName = "Big Endian (BE)";
}
else
{
    static assert(false, "Endianness could not be determined.");
}

version (Windows)
{
    public enum OperatingSystem operatingSystem = OperatingSystem.windows;
    public enum string operatingSystemName = "Windows";
}
else version (Posix)
{
    version (FreeBSD)
    {
        public enum OperatingSystem operatingSystem = OperatingSystem.freebsd;
        public enum string operatingSystemName = "FreeBSD";
    }
    else version (OpenBSD)
    {
        public enum OperatingSystem operatingSystem = OperatingSystem.openbsd;
        public enum string operatingSystemName = "OpenBSD";
    }
    else version (BSD)
    {
        public enum OperatingSystem operatingSystem = OperatingSystem.bsd;
        public enum string operatingSystemName = "BSD";
    }
    else version (AIX)
    {
        public enum OperatingSystem operatingSystem = OperatingSystem.aix;
        public enum string operatingSystemName = "AIX";
    }
    else version (Solaris)
    {
        public enum OperatingSystem operatingSystem = OperatingSystem.solaris;
        public enum string operatingSystemName = "Solaris";
    }
    else version (Hurd)
    {
        public enum OperatingSystem operatingSystem = OperatingSystem.hurd;
        public enum string operatingSystemName = "Hurd";
    }
    else version (linux)
    {
        public enum OperatingSystem operatingSystem = OperatingSystem.linux;
        public enum string operatingSystemName = "Linux";
    }
    else version (OSX)
    {
        public enum OperatingSystem operatingSystem = OperatingSystem.osx;
        public enum string operatingSystemName = "OS X";
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
    public enum EmulationLayer emulationLayer = EmulationLayer.cygwin;
    public enum string emulationLayerName = "Cygwin";
}
else version (MinGW)
{
    public enum EmulationLayer emulationLayer = EmulationLayer.mingw;
    public enum string emulationLayerName = "MinGW";
}
else
{
    public enum EmulationLayer emulationLayer = EmulationLayer.none;
    public enum string emulationLayerName = "None";
}
