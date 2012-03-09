module mci.debugger.protocol;

import std.variant,
       mci.core.common,
       mci.core.io,
       mci.core.code.opcodes;

public enum uint protocolVersion = 1;

public enum DebuggerClientOpCode : ubyte
{
    query = 0,
    start = 1,
    pause = 2,
    continue_ = 3,
    exit = 4,
    thread = 5,
    frame = 6,
    breakpoint = 7,
    catchpoint = 8,
    disassemble = 9,
    inspect = 10,
}

public enum DebuggerServerOpCode : ubyte
{
    result = 0,
    started = 1,
    paused = 2,
    continued = 3,
    exited = 4,
    thread = 5,
    frame = 6,
    break_ = 7,
    catch_ = 8,
    unhandled = 9,
    disassembly = 10,
    values = 11,
}

public enum size_t packetHeaderSize = ubyte.sizeof + uint.sizeof + uint.sizeof;

public interface Packet
{
    @property public ubyte opCode();

    public void write(BinaryWriter writer)
    in
    {
        assert(writer);
    }

    public void read(BinaryReader reader)
    in
    {
        assert(reader);
    }
}

public class ClientQueryPacket : Packet
{
    @property public ubyte opCode()
    {
        return DebuggerClientOpCode.query;
    }

    public void write(BinaryWriter writer)
    {
    }

    public void read(BinaryReader reader)
    {
    }
}

public class ClientStartPacket : Packet
{
    @property public ubyte opCode()
    {
        return DebuggerClientOpCode.start;
    }

    public void write(BinaryWriter writer)
    {
    }

    public void read(BinaryReader reader)
    {
    }
}

public class ClientPausePacket : Packet
{
    @property public ubyte opCode()
    {
        return DebuggerClientOpCode.pause;
    }

    public void write(BinaryWriter writer)
    {
    }

    public void read(BinaryReader reader)
    {
    }
}

public class ClientContinuePacket : Packet
{
    @property public ubyte opCode()
    {
        return DebuggerClientOpCode.continue_;
    }

    public void write(BinaryWriter writer)
    {
    }

    public void read(BinaryReader reader)
    {
    }
}

public class ClientExitPacket : Packet
{
    @property public ubyte opCode()
    {
        return DebuggerClientOpCode.exit;
    }

    public void write(BinaryWriter writer)
    {
    }

    public void read(BinaryReader reader)
    {
    }
}

public enum ThreadAction : ubyte
{
    list = 0,
    switch_ = 1,
}

public class ClientThreadPacket : Packet
{
    public ThreadAction action;
    public ulong thread;
    public ulong[] threads;

    @property public ubyte opCode()
    {
        return DebuggerClientOpCode.thread;
    }

    public void write(BinaryWriter writer)
    {
        writer.write(action);

        final switch (action)
        {
            case ThreadAction.list:
                writer.write(cast(uint)threads.length);
                writer.writeArray(threads);
                break;
            case ThreadAction.switch_:
                writer.write(thread);
                break;
        }
    }

    public void read(BinaryReader reader)
    {
        action = reader.read!ThreadAction();

        final switch (action)
        {
            case ThreadAction.list:
                threads = reader.readArray!(ulong[])(reader.read!uint());
                break;
            case ThreadAction.switch_:
                thread = reader.read!ulong();
                break;
        }
    }
}

public class ClientFramePacket : Packet
{
    public uint frame;

    @property public ubyte opCode()
    {
        return DebuggerClientOpCode.frame;
    }

    public void write(BinaryWriter writer)
    {
        writer.write(frame);
    }

    public void read(BinaryReader reader)
    {
        frame = reader.read!uint();
    }
}

public enum PointAction : ubyte
{
    add = 0,
    remove = 1,
}

public class ClientBreakpointPacket : Packet
{
    public PointAction action;
    public string moduleName;
    public string functionName;
    public string basicBlockName;
    public uint instructionIndex;

    @property public ubyte opCode()
    {
        return DebuggerClientOpCode.breakpoint;
    }

    public void write(BinaryWriter writer)
    {
        writer.write(action);
        writer.write(cast(uint)moduleName.length);
        writer.writeArray(moduleName);
        writer.write(cast(uint)functionName.length);
        writer.writeArray(functionName);
        writer.write(cast(uint)basicBlockName.length);
        writer.writeArray(basicBlockName);
        writer.write(instructionIndex);
    }

    public void read(BinaryReader reader)
    {
        action = reader.read!PointAction();
        moduleName = reader.readArray!string(reader.read!uint());
        functionName = reader.readArray!string(reader.read!uint());
        basicBlockName = reader.readArray!string(reader.read!uint());
        instructionIndex = reader.read!uint();
    }
}

public class ClientCatchpointPacket : Packet
{
    public PointAction action;
    public string moduleName;
    public string typeName;

    @property public ubyte opCode()
    {
        return DebuggerClientOpCode.catchpoint;
    }

    public void write(BinaryWriter writer)
    {
        writer.write(action);
        writer.write(cast(uint)moduleName.length);
        writer.writeArray(moduleName);
        writer.write(cast(uint)typeName.length);
        writer.writeArray(typeName);
    }

    public void read(BinaryReader reader)
    {
        action = reader.read!PointAction();
        moduleName = reader.readArray!string(reader.read!uint());
        typeName = reader.readArray!string(reader.read!uint());
    }
}

public class ClientDisassemblePacket : Packet
{
    public string moduleName;
    public string functionName;

    @property public ubyte opCode()
    {
        return DebuggerClientOpCode.disassemble;
    }

    public void write(BinaryWriter writer)
    {
        writer.write(cast(uint)moduleName.length);
        writer.writeArray(moduleName);
        writer.write(cast(uint)functionName.length);
        writer.writeArray(functionName);
    }

    public void read(BinaryReader reader)
    {
        moduleName = reader.readArray!string(reader.read!uint());
        functionName = reader.readArray!string(reader.read!uint());
    }
}

// TODO: Specify a wire format for types and values.
public class ClientInspectPacket : Packet
{
    @property public ubyte opCode()
    {
        return DebuggerClientOpCode.inspect;
    }

    public void write(BinaryWriter writer)
    {
    }

    public void read(BinaryReader reader)
    {
    }
}

public class ServerResultPacket : Packet
{
    public Compiler compiler;
    public Architecture architecture;
    public Endianness endianness;
    public OperatingSystem operatingSystem;
    public EmulationLayer emulationLayer;
    public bool is32Bit;

    @property public ubyte opCode()
    {
        return DebuggerServerOpCode.result;
    }

    public void write(BinaryWriter writer)
    {
        writer.write(compiler);
        writer.write(architecture);
        writer.write(endianness);
        writer.write(operatingSystem);
        writer.write(emulationLayer);
        writer.write(is32Bit);
    }

    public void read(BinaryReader reader)
    {
        compiler = reader.read!Compiler();
        architecture = reader.read!Architecture();
        endianness = reader.read!Endianness();
        operatingSystem = reader.read!OperatingSystem();
        emulationLayer = reader.read!EmulationLayer();
        is32Bit = reader.read!bool();
    }
}

public class ServerStartedPacket : Packet
{
    @property public ubyte opCode()
    {
        return DebuggerServerOpCode.started;
    }

    public void write(BinaryWriter writer)
    {
    }

    public void read(BinaryReader reader)
    {
    }
}

public class ServerPausedPacket : Packet
{
    @property public ubyte opCode()
    {
        return DebuggerServerOpCode.paused;
    }

    public void write(BinaryWriter writer)
    {
    }

    public void read(BinaryReader reader)
    {
    }
}

public class ServerContinuedPacket : Packet
{
    @property public ubyte opCode()
    {
        return DebuggerServerOpCode.continued;
    }

    public void write(BinaryWriter writer)
    {
    }

    public void read(BinaryReader reader)
    {
    }
}

public class ServerExitedPacket : Packet
{
    @property public ubyte opCode()
    {
        return DebuggerServerOpCode.exited;
    }

    public void write(BinaryWriter writer)
    {
    }

    public void read(BinaryReader reader)
    {
    }
}

public class ServerThreadPacket : Packet
{
    public ThreadAction action;
    public ulong thread;
    public ulong[] threads;

    @property public ubyte opCode()
    {
        return DebuggerServerOpCode.thread;
    }

    public void write(BinaryWriter writer)
    {
        writer.write(action);

        final switch (action)
        {
            case ThreadAction.list:
                writer.write(cast(uint)threads.length);
                writer.writeArray(threads);
                break;
            case ThreadAction.switch_:
                writer.write(thread);
                break;
        }
    }

    public void read(BinaryReader reader)
    {
        action = reader.read!ThreadAction();

        final switch (action)
        {
            case ThreadAction.list:
                threads = reader.readArray!(ulong[])(reader.read!uint());
                break;
            case ThreadAction.switch_:
                thread = reader.read!ulong();
                break;
        }
    }
}

public class ServerFramePacket : Packet
{
    public ubyte frame;

    @property public ubyte opCode()
    {
        return DebuggerServerOpCode.frame;
    }

    public void write(BinaryWriter writer)
    {
        writer.write(frame);
    }

    public void read(BinaryReader reader)
    {
        frame = reader.read!ubyte();
    }
}

public class ServerBreakPacket : Packet
{
    public string moduleName;
    public string functionName;
    public string basicBlockName;
    public uint instructionIndex;

    @property public ubyte opCode()
    {
        return DebuggerServerOpCode.break_;
    }

    public void write(BinaryWriter writer)
    {
        writer.write(cast(uint)moduleName.length);
        writer.writeArray(moduleName);
        writer.write(cast(uint)functionName.length);
        writer.writeArray(functionName);
        writer.write(cast(uint)basicBlockName.length);
        writer.writeArray(basicBlockName);
        writer.write(instructionIndex);
    }

    public void read(BinaryReader reader)
    {
        moduleName = reader.readArray!string(reader.read!uint());
        functionName = reader.readArray!string(reader.read!uint());
        basicBlockName = reader.readArray!string(reader.read!uint());
        instructionIndex = reader.read!uint();
    }
}

public class ServerCatchPacket : Packet
{
    public string moduleName;
    public string functionName;
    public string basicBlockName;
    public uint instructionIndex;
    public ulong exceptionObjectAddress;

    @property public ubyte opCode()
    {
        return DebuggerServerOpCode.catch_;
    }

    public void write(BinaryWriter writer)
    {
        writer.write(cast(uint)moduleName.length);
        writer.writeArray(moduleName);
        writer.write(cast(uint)functionName.length);
        writer.writeArray(functionName);
        writer.write(cast(uint)basicBlockName.length);
        writer.writeArray(basicBlockName);
        writer.write(instructionIndex);
        writer.write(exceptionObjectAddress);
    }

    public void read(BinaryReader reader)
    {
        moduleName = reader.readArray!string(reader.read!uint());
        functionName = reader.readArray!string(reader.read!uint());
        basicBlockName = reader.readArray!string(reader.read!uint());
        instructionIndex = reader.read!uint();
        exceptionObjectAddress = reader.read!ulong();
    }
}

public class ServerUnhandledPacket : Packet
{
    public string moduleName;
    public string functionName;
    public string basicBlockName;
    public uint instructionIndex;
    public ulong exceptionObjectAddress;

    @property public ubyte opCode()
    {
        return DebuggerServerOpCode.unhandled;
    }

    public void write(BinaryWriter writer)
    {
        writer.write(cast(uint)moduleName.length);
        writer.writeArray(moduleName);
        writer.write(cast(uint)functionName.length);
        writer.writeArray(functionName);
        writer.write(cast(uint)basicBlockName.length);
        writer.writeArray(basicBlockName);
        writer.write(instructionIndex);
        writer.write(exceptionObjectAddress);
    }

    public void read(BinaryReader reader)
    {
        moduleName = reader.readArray!string(reader.read!uint());
        functionName = reader.readArray!string(reader.read!uint());
        basicBlockName = reader.readArray!string(reader.read!uint());
        instructionIndex = reader.read!uint();
        exceptionObjectAddress = reader.read!ulong();
    }
}

public struct DisassemblyInstruction
{
    public OperationCode opCode;
    public string targetRegister;
    public string sourceRegister1;
    public string sourceRegister2;
    public string sourceRegister3;
}

public class ServerDisassemblyPacket : Packet
{
    public string moduleName;
    public string functionName;
    public DisassemblyInstruction[][string] basicBlocks;

    @property public ubyte opCode()
    {
        return DebuggerServerOpCode.disassembly;
    }

    public void write(BinaryWriter writer)
    {
        writer.write(cast(uint)moduleName.length);
        writer.writeArray(moduleName);
        writer.write(cast(uint)functionName.length);
        writer.writeArray(functionName);
        writer.write(cast(uint)basicBlocks.length);

        foreach (k, v; basicBlocks)
        {
            writer.write(cast(uint)k.length);
            writer.writeArray(k);
            writer.write(cast(uint)v.length);

            foreach (disasm; v)
            {
                writer.write(disasm.opCode);
                writer.write(cast(uint)disasm.targetRegister.length);
                writer.writeArray(disasm.targetRegister);
                writer.write(cast(uint)disasm.sourceRegister1.length);
                writer.writeArray(disasm.sourceRegister1);
                writer.write(cast(uint)disasm.sourceRegister2.length);
                writer.writeArray(disasm.sourceRegister2);
                writer.write(cast(uint)disasm.sourceRegister3.length);
                writer.writeArray(disasm.sourceRegister3);
            }
        }
    }

    public void read(BinaryReader reader)
    {
        moduleName = reader.readArray!string(reader.read!uint());
        functionName = reader.readArray!string(reader.read!uint());

        auto count = reader.read!uint();

        for (uint i = 0; i < count; i++)
        {
            auto bb = reader.readArray!string(reader.read!uint());
            auto insns = reader.read!uint();

            for (uint j = 0; j < insns; j++)
            {
                basicBlocks[bb] ~= DisassemblyInstruction(reader.read!OperationCode(),
                                                          reader.readArray!string(reader.read!uint()),
                                                          reader.readArray!string(reader.read!uint()),
                                                          reader.readArray!string(reader.read!uint()),
                                                          reader.readArray!string(reader.read!uint()));
            }
        }
    }
}

// TODO: See ClientInspectPacket note.
public class ServerValuesPacket : Packet
{
    @property public ubyte opCode()
    {
        return DebuggerServerOpCode.values;
    }

    public void write(BinaryWriter writer)
    {
    }

    public void read(BinaryReader reader)
    {
    }
}
