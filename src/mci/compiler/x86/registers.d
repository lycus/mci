module mci.compiler.x86.registers;

import mci.core.nullable,
       mci.compiler.registers;

// 32-bit x86 GPRs.

public final class EAX : MachineRegister
{
    mixin RegisterBody!("EAX", "eax", RegisterCategory.general, RegisterSize.word);
}

public final class EBX : MachineRegister
{
    mixin RegisterBody!("EBX", "ebx", RegisterCategory.general, RegisterSize.word);
}

public final class ECX : MachineRegister
{
    mixin RegisterBody!("ECX", "ecx", RegisterCategory.general, RegisterSize.word);
}

public final class EDX : MachineRegister
{
    mixin RegisterBody!("EDX", "edx", RegisterCategory.general, RegisterSize.word);
}

public final class ESI : MachineRegister
{
    mixin RegisterBody!("ESI", "esi", RegisterCategory.general, RegisterSize.word);
}

public final class EDI : MachineRegister
{
    mixin RegisterBody!("EDI", "edi", RegisterCategory.general, RegisterSize.word);
}

public final class ESP : MachineRegister
{
    mixin RegisterBody!("ESP", "esp", RegisterCategory.general, RegisterSize.word);
}

public final class EBP : MachineRegister
{
    mixin RegisterBody!("EBP", "ebp", RegisterCategory.general, RegisterSize.word);
}

// 32-bit x86 vector registers.

public final class XMM0 : MachineRegister
{
    mixin RegisterBody!("XMM0", "xmm0", RegisterCategory.vector, RegisterSize.qword | RegisterSize.oword);
}

public final class XMM1 : MachineRegister
{
    mixin RegisterBody!("XMM1", "xmm1", RegisterCategory.vector, RegisterSize.qword | RegisterSize.oword);
}

public final class XMM2 : MachineRegister
{
    mixin RegisterBody!("XMM2", "xmm2", RegisterCategory.vector, RegisterSize.qword | RegisterSize.oword);
}

public final class XMM3 : MachineRegister
{
    mixin RegisterBody!("XMM3", "xmm3", RegisterCategory.vector, RegisterSize.qword | RegisterSize.oword);
}

public final class XMM4 : MachineRegister
{
    mixin RegisterBody!("XMM4", "xmm4", RegisterCategory.vector, RegisterSize.qword | RegisterSize.oword);
}

public final class XMM5 : MachineRegister
{
    mixin RegisterBody!("XMM5", "xmm5", RegisterCategory.vector, RegisterSize.qword | RegisterSize.oword);
}

public final class XMM6 : MachineRegister
{
    mixin RegisterBody!("XMM6", "xmm6", RegisterCategory.vector, RegisterSize.qword | RegisterSize.oword);
}

public final class XMM7 : MachineRegister
{
    mixin RegisterBody!("XMM7", "xmm7", RegisterCategory.vector, RegisterSize.qword | RegisterSize.oword);
}

public final class YMM0 : MachineRegister
{
    mixin RegisterBody!("YMM0", "ymm0", RegisterCategory.vector, RegisterSize.oword);
}

public final class YMM1 : MachineRegister
{
    mixin RegisterBody!("YMM1", "ymm1", RegisterCategory.vector, RegisterSize.oword);
}

public final class YMM2 : MachineRegister
{
    mixin RegisterBody!("YMM2", "ymm2", RegisterCategory.vector, RegisterSize.oword);
}

public final class YMM3 : MachineRegister
{
    mixin RegisterBody!("YMM3", "ymm3", RegisterCategory.vector, RegisterSize.oword);
}

public final class YMM4 : MachineRegister
{
    mixin RegisterBody!("YMM4", "ymm4", RegisterCategory.vector, RegisterSize.oword);
}

public final class YMM5 : MachineRegister
{
    mixin RegisterBody!("YMM5", "ymm5", RegisterCategory.vector, RegisterSize.oword);
}

public final class YMM6 : MachineRegister
{
    mixin RegisterBody!("YMM6", "ymm6", RegisterCategory.vector, RegisterSize.oword);
}

public final class YMM7 : MachineRegister
{
    mixin RegisterBody!("YMM7", "ymm7", RegisterCategory.vector, RegisterSize.oword);
}

// 32-bit x86 SPRs.

public final class EIP : MachineRegister
{
    mixin RegisterBody!("EIP", "eip", RegisterCategory.special, RegisterSize.word);
}

public final class EFLAGS : MachineRegister
{
    mixin RegisterBody!("EFLAGS", "eflags", RegisterCategory.special, RegisterSize.word);
}

public final class MXCSR : MachineRegister
{
    mixin RegisterBody!("MXCSR", "mxcsr", RegisterCategory.special, RegisterSize.word);
}

// 64-bit x86 GPRs.

public final class RAX : MachineRegister
{
    mixin RegisterBody!("RAX", "rax", RegisterCategory.general, RegisterSize.dword);
}

public final class RBX : MachineRegister
{
    mixin RegisterBody!("RBX", "rbx", RegisterCategory.general, RegisterSize.dword);
}

public final class RCX : MachineRegister
{
    mixin RegisterBody!("RCX", "rcx", RegisterCategory.general, RegisterSize.dword);
}

public final class RDX : MachineRegister
{
    mixin RegisterBody!("RDX", "rdx", RegisterCategory.general, RegisterSize.dword);
}

public final class RSI : MachineRegister
{
    mixin RegisterBody!("RSI", "rsi", RegisterCategory.general, RegisterSize.dword);
}

public final class RDI : MachineRegister
{
    mixin RegisterBody!("RDI", "rdi", RegisterCategory.general, RegisterSize.dword);
}

public final class RSP : MachineRegister
{
    mixin RegisterBody!("RSP", "rsp", RegisterCategory.general, RegisterSize.dword);
}

public final class RBP : MachineRegister
{
    mixin RegisterBody!("RBP", "rbp", RegisterCategory.general, RegisterSize.dword);
}

public final class R8 : MachineRegister
{
    mixin RegisterBody!("R8", "r8", RegisterCategory.general, RegisterSize.dword);
}

public final class R9 : MachineRegister
{
    mixin RegisterBody!("R9", "r9", RegisterCategory.general, RegisterSize.dword);
}

public final class R10 : MachineRegister
{
    mixin RegisterBody!("R10", "r10", RegisterCategory.general, RegisterSize.dword);
}

public final class R11 : MachineRegister
{
    mixin RegisterBody!("R11", "r11", RegisterCategory.general, RegisterSize.dword);
}

public final class R12 : MachineRegister
{
    mixin RegisterBody!("R12", "r12", RegisterCategory.general, RegisterSize.dword);
}

public final class R13 : MachineRegister
{
    mixin RegisterBody!("R13", "r13", RegisterCategory.general, RegisterSize.dword);
}

public final class R14 : MachineRegister
{
    mixin RegisterBody!("R14", "r14", RegisterCategory.general, RegisterSize.dword);
}

public final class R15 : MachineRegister
{
    mixin RegisterBody!("R15", "r15", RegisterCategory.general, RegisterSize.dword);
}

// 64-bit x86 vector registers.

public final class XMM8 : MachineRegister
{
    mixin RegisterBody!("XMM8", "xmm8", RegisterCategory.vector, RegisterSize.qword | RegisterSize.oword);
}

public final class XMM9 : MachineRegister
{
    mixin RegisterBody!("XMM9", "xmm9", RegisterCategory.vector, RegisterSize.qword | RegisterSize.oword);
}

public final class XMM10 : MachineRegister
{
    mixin RegisterBody!("XMM10", "xmm10", RegisterCategory.vector, RegisterSize.qword | RegisterSize.oword);
}

public final class XMM11 : MachineRegister
{
    mixin RegisterBody!("XMM11", "xmm11", RegisterCategory.vector, RegisterSize.qword | RegisterSize.oword);
}

public final class XMM12 : MachineRegister
{
    mixin RegisterBody!("XMM12", "xmm12", RegisterCategory.vector, RegisterSize.qword | RegisterSize.oword);
}

public final class XMM13 : MachineRegister
{
    mixin RegisterBody!("XMM13", "xmm13", RegisterCategory.vector, RegisterSize.qword | RegisterSize.oword);
}

public final class XMM14 : MachineRegister
{
    mixin RegisterBody!("XMM14", "xmm14", RegisterCategory.vector, RegisterSize.qword | RegisterSize.oword);
}

public final class XMM15 : MachineRegister
{
    mixin RegisterBody!("XMM15", "xmm15", RegisterCategory.vector, RegisterSize.qword | RegisterSize.oword);
}

public final class YMM8 : MachineRegister
{
    mixin RegisterBody!("YMM8", "ymm8", RegisterCategory.vector, RegisterSize.oword);
}

public final class YMM9 : MachineRegister
{
    mixin RegisterBody!("YMM9", "ymm9", RegisterCategory.vector, RegisterSize.oword);
}

public final class YMM10 : MachineRegister
{
    mixin RegisterBody!("YMM10", "ymm10", RegisterCategory.vector, RegisterSize.oword);
}

public final class YMM11 : MachineRegister
{
    mixin RegisterBody!("YMM11", "ymm11", RegisterCategory.vector, RegisterSize.oword);
}

public final class YMM12 : MachineRegister
{
    mixin RegisterBody!("YMM12", "ymm12", RegisterCategory.vector, RegisterSize.oword);
}

public final class YMM13 : MachineRegister
{
    mixin RegisterBody!("YMM13", "ymm13", RegisterCategory.vector, RegisterSize.oword);
}

public final class YMM14 : MachineRegister
{
    mixin RegisterBody!("YMM14", "ymm14", RegisterCategory.vector, RegisterSize.oword);
}

public final class YMM15 : MachineRegister
{
    mixin RegisterBody!("YMM15", "ymm15", RegisterCategory.vector, RegisterSize.oword);
}

// 64-bit x86 SPRs.

public final class RIP : MachineRegister
{
    mixin RegisterBody!("RIP", "rip", RegisterCategory.special, RegisterSize.dword);
}

public final class RFLAGS : MachineRegister
{
    mixin RegisterBody!("RFLAGS", "rflags", RegisterCategory.special, RegisterSize.dword);
}

// 80-bit x87 FPRs. Note that we treat these as 64-bit registers
// even though they're really 80-bit. We generally don't care about
// x87's extended double precision format since we only support
// IEEE-standardized 32-bit and 64-bit floats. Further, keep in
// mind that x87 uses a register stack.

public final class ST0 : MachineRegister
{
    mixin RegisterBody!("ST0", "st0", RegisterCategory.float_, RegisterSize.dword);
}

public final class ST1 : MachineRegister
{
    mixin RegisterBody!("ST1", "st1", RegisterCategory.float_, RegisterSize.dword);
}

public final class ST2 : MachineRegister
{
    mixin RegisterBody!("ST2", "st2", RegisterCategory.float_, RegisterSize.dword);
}

public final class ST3 : MachineRegister
{
    mixin RegisterBody!("ST3", "st3", RegisterCategory.float_, RegisterSize.dword);
}

public final class ST4 : MachineRegister
{
    mixin RegisterBody!("ST4", "st4", RegisterCategory.float_, RegisterSize.dword);
}

public final class ST5 : MachineRegister
{
    mixin RegisterBody!("ST5", "st5", RegisterCategory.float_, RegisterSize.dword);
}

public final class ST6 : MachineRegister
{
    mixin RegisterBody!("ST6", "st6", RegisterCategory.float_, RegisterSize.dword);
}

public final class ST7 : MachineRegister
{
    mixin RegisterBody!("ST7", "st7", RegisterCategory.float_, RegisterSize.dword);
}
