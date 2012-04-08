module mci.debugger.client;

import core.thread,
       std.signals,
       std.socket,
       mci.core.io,
       mci.debugger.protocol,
       mci.debugger.utilities;

public abstract class DebuggerClient
{
    private Thread _thread;
    private TcpSocket _socket;
    private Address _address;

    invariant()
    {
        assert(_address);
    }

    protected this(Address address)
    in
    {
        assert(address);
        assert(address.addressFamily == AddressFamily.INET || address.addressFamily == AddressFamily.INET6);
    }
    body
    {
        _address = address;
        _socket = new typeof(_socket)(address.addressFamily);
    }

    public final void start()
    in
    {
        assert(_socket);
        assert(!_thread);
    }
    body
    {
        _thread = new typeof(_thread)(&run);
        _thread.isDaemon = true;
        _thread.start();
    }

    public final void stop()
    in
    {
        assert(_socket);
        assert(_thread);
    }
    body
    {
        _thread = null;
    }

    private void run()
    {
        try
            _socket.connect(_address);
        catch (SocketOSException)
        {
            kill();
            return;
        }

        handleConnect(_socket);

        while (_thread)
        {
            auto buf = new ubyte[packetHeaderSize];

            // Read the header. This contains opcode, protocol version, and length.
            if (!receive(_socket, buf))
                break;

            auto br = new BinaryReader(new MemoryStream(buf, false));
            auto header = readHeader(br);

            br.stream.close();

            buf = new ubyte[header.z];

            // Next up, we fetch the body of the packet.
            if (header.z && !receive(_socket, buf))
                break;

            br = new BinaryReader(new MemoryStream(buf, false));

            // We can't use final switch. The thing is, the client could send a bad
            // opcode, so we need to handle that case gracefully.
            switch (cast(DebuggerServerOpCode)header.x)
            {
                case DebuggerServerOpCode.result:
                    auto pkt = new ServerResultPacket();
                    pkt.read(br);
                    handle(_socket, pkt);
                    break;
                case DebuggerServerOpCode.started:
                    auto pkt = new ServerStartedPacket();
                    pkt.read(br);
                    handle(_socket, pkt);
                    break;
                case DebuggerServerOpCode.paused:
                    auto pkt = new ServerPausedPacket();
                    pkt.read(br);
                    handle(_socket, pkt);
                    break;
                case DebuggerServerOpCode.continued:
                    auto pkt = new ServerContinuedPacket();
                    pkt.read(br);
                    handle(_socket, pkt);
                    break;
                case DebuggerServerOpCode.exited:
                    auto pkt = new ServerExitedPacket();
                    pkt.read(br);
                    handle(_socket, pkt);
                    break;
                case DebuggerServerOpCode.thread:
                    auto pkt = new ServerThreadPacket();
                    pkt.read(br);
                    handle(_socket, pkt);
                    break;
                case DebuggerServerOpCode.frame:
                    auto pkt = new ServerFramePacket();
                    pkt.read(br);
                    handle(_socket, pkt);
                    break;
                case DebuggerServerOpCode.break_:
                    auto pkt = new ServerBreakPacket();
                    pkt.read(br);
                    handle(_socket, pkt);
                    break;
                case DebuggerServerOpCode.catch_:
                    auto pkt = new ServerCatchPacket();
                    pkt.read(br);
                    handle(_socket, pkt);
                    break;
                case DebuggerServerOpCode.unhandled:
                    auto pkt = new ServerUnhandledPacket();
                    pkt.read(br);
                    handle(_socket, pkt);
                    break;
                case DebuggerServerOpCode.disassembly:
                    auto pkt = new ServerDisassemblyPacket();
                    pkt.read(br);
                    handle(_socket, pkt);
                    break;
                case DebuggerServerOpCode.values:
                    auto pkt = new ServerValuesPacket();
                    pkt.read(br);
                    handle(_socket, pkt);
                    break;
                default:
                    br.stream.close();
                    kill();
                    return;
            }

            br.stream.close();
        }

        kill();
    }

    private void kill()
    {
        handleDisconnect(_socket);
        _socket.shutdown(SocketShutdown.BOTH);
        _socket.close();
        _socket = null;
    }

    public final void send(Packet packet)
    in
    {
        assert(_socket);
        assert(_thread);
        assert(packet);
    }
    body
    {
        auto stream = new MemoryStream(new ubyte[packetHeaderSize]);
        auto bw = new BinaryWriter(stream);
        stream.position = packetHeaderSize;

        packet.write(bw);
        stream.position = 0;

        writeHeader(bw, packet.opCode, protocolVersion, cast(uint)(stream.length - packetHeaderSize));

        if (!.send(_socket, stream.data))
        {
            kill();
            return;
        }

        stream.close();
    }

    protected void handleConnect(Socket socket)
    {
    }

    protected void handleDisconnect(Socket socket)
    {
    }

    protected abstract void handle(Socket socket, ServerResultPacket packet);

    protected abstract void handle(Socket socket, ServerStartedPacket packet);

    protected abstract void handle(Socket socket, ServerPausedPacket packet);

    protected abstract void handle(Socket socket, ServerContinuedPacket packet);

    protected abstract void handle(Socket socket, ServerExitedPacket packet);

    protected abstract void handle(Socket socket, ServerThreadPacket packet);

    protected abstract void handle(Socket socket, ServerFramePacket packet);

    protected abstract void handle(Socket socket, ServerBreakPacket packet);

    protected abstract void handle(Socket socket, ServerCatchPacket packet);

    protected abstract void handle(Socket socket, ServerUnhandledPacket packet);

    protected abstract void handle(Socket socket, ServerDisassemblyPacket packet);

    protected abstract void handle(Socket socket, ServerValuesPacket packet);
}

public final class SignalDebuggerClient : DebuggerClient
{
    public this(Address address)
    in
    {
        assert(address);
        assert(address.addressFamily == AddressFamily.INET || address.addressFamily == AddressFamily.INET6);
    }
    body
    {
        super(address);
    }

    protected override void handleConnect(Socket socket)
    {
        connected.emit(socket);
    }

    protected override void handleDisconnect(Socket socket)
    {
        disconnected.emit(socket);
    }

    protected override void handle(Socket socket, ServerResultPacket packet)
    {
        received.emit(socket, packet);
    }

    protected override void handle(Socket socket, ServerStartedPacket packet)
    {
        received.emit(socket, packet);
    }

    protected override void handle(Socket socket, ServerPausedPacket packet)
    {
        received.emit(socket, packet);
    }

    protected override void handle(Socket socket, ServerContinuedPacket packet)
    {
        received.emit(socket, packet);
    }

    protected override void handle(Socket socket, ServerExitedPacket packet)
    {
        received.emit(socket, packet);
    }

    protected override void handle(Socket socket, ServerThreadPacket packet)
    {
        received.emit(socket, packet);
    }

    protected override void handle(Socket socket, ServerFramePacket packet)
    {
        received.emit(socket, packet);
    }

    protected override void handle(Socket socket, ServerBreakPacket packet)
    {
        received.emit(socket, packet);
    }

    protected override void handle(Socket socket, ServerCatchPacket packet)
    {
        received.emit(socket, packet);
    }

    protected override void handle(Socket socket, ServerUnhandledPacket packet)
    {
        received.emit(socket, packet);
    }

    protected override void handle(Socket socket, ServerDisassemblyPacket packet)
    {
        received.emit(socket, packet);
    }

    protected override void handle(Socket socket, ServerValuesPacket packet)
    {
        received.emit(socket, packet);
    }

    mixin Signal!Socket connected;
    mixin Signal!Socket disconnected;
    mixin Signal!(Socket, Packet) received;
}
