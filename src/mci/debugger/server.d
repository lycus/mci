module mci.debugger.server;

import core.thread,
       std.signals,
       std.socket,
       mci.core.io,
       mci.debugger.protocol,
       mci.debugger.utilities;

public abstract class DebuggerServer
{
    private Thread _thread;
    private TcpSocket _socket;
    private Socket _client;

    protected this(Address address)
    in
    {
        assert(address);
        assert(address.addressFamily == AddressFamily.INET || address.addressFamily == AddressFamily.INET6);
    }
    body
    {
        _socket = new typeof(_socket)(address.addressFamily);

        _socket.bind(address);
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
        {
            _socket.listen(1);
        }
        catch (SocketOSException)
        {
            kill();
            return;
        }

        try
        {
            _client = _socket.accept();
        }
        catch (SocketAcceptException)
        {
            kill();
            return;
        }

        handleConnect(_client);

        while (_thread)
        {
            auto buf = new ubyte[packetHeaderSize];

            // Read the header. This contains opcode, protocol version, and length.
            if (!receive(_client, buf))
                break;

            auto br = new BinaryReader(new MemoryStream(buf, false));
            auto header = readHeader(br);

            br.stream.close();

            buf = new ubyte[header.z];

            // Next up, we fetch the body of the packet.
            if (header.z && !receive(_client, buf))
                break;

            br = new BinaryReader(new MemoryStream(buf, false));

            // We can't use final switch. The thing is, the client could send a bad
            // opcode, so we need to handle that case gracefully.
            switch (cast(DebuggerClientOpCode)header.x)
            {
                case DebuggerClientOpCode.query:
                    auto pkt = new ClientQueryPacket();
                    pkt.read(br);
                    handle(_client, pkt);
                    break;
                case DebuggerClientOpCode.start:
                    auto pkt = new ClientStartPacket();
                    pkt.read(br);
                    handle(_client, pkt);
                    break;
                case DebuggerClientOpCode.pause:
                    auto pkt = new ClientPausePacket();
                    pkt.read(br);
                    handle(_client, pkt);
                    break;
                case DebuggerClientOpCode.continue_:
                    auto pkt = new ClientContinuePacket();
                    pkt.read(br);
                    handle(_client, pkt);
                    break;
                case DebuggerClientOpCode.exit:
                    auto pkt = new ClientExitPacket();
                    pkt.read(br);
                    handle(_client, pkt);
                    break;
                case DebuggerClientOpCode.thread:
                    auto pkt = new ClientThreadPacket();
                    pkt.read(br);
                    handle(_client, pkt);
                    break;
                case DebuggerClientOpCode.frame:
                    auto pkt = new ClientFramePacket();
                    pkt.read(br);
                    handle(_client, pkt);
                    break;
                case DebuggerClientOpCode.breakpoint:
                    auto pkt = new ClientBreakpointPacket();
                    pkt.read(br);
                    handle(_client, pkt);
                    break;
                case DebuggerClientOpCode.catchpoint:
                    auto pkt = new ClientCatchpointPacket();
                    pkt.read(br);
                    handle(_client, pkt);
                    break;
                case DebuggerClientOpCode.disassemble:
                    auto pkt = new ClientDisassemblePacket();
                    pkt.read(br);
                    handle(_client, pkt);
                    break;
                case DebuggerClientOpCode.inspect:
                    auto pkt = new ClientInspectPacket();
                    pkt.read(br);
                    handle(_client, pkt);
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
        _socket.shutdown(SocketShutdown.BOTH);
        _socket.close();
        _socket = null;

        if (_client)
        {
            handleDisconnect(_client);
            _client.shutdown(SocketShutdown.BOTH);
            _client.close();
        }
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

        if (!.send(_client, stream.data))
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

    protected abstract void handle(Socket client, ClientQueryPacket packet);

    protected abstract void handle(Socket client, ClientStartPacket packet);

    protected abstract void handle(Socket client, ClientPausePacket packet);

    protected abstract void handle(Socket client, ClientContinuePacket packet);

    protected abstract void handle(Socket client, ClientExitPacket packet);

    protected abstract void handle(Socket client, ClientThreadPacket packet);

    protected abstract void handle(Socket client, ClientFramePacket packet);

    protected abstract void handle(Socket client, ClientBreakpointPacket packet);

    protected abstract void handle(Socket client, ClientCatchpointPacket packet);

    protected abstract void handle(Socket client, ClientDisassemblePacket packet);

    protected abstract void handle(Socket client, ClientInspectPacket packet);
}

public final class SignalDebuggerServer : DebuggerServer
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

    protected override void handle(Socket client, ClientQueryPacket packet)
    {
        received.emit(client, packet);
    }

    protected override void handle(Socket client, ClientStartPacket packet)
    {
        received.emit(client, packet);
    }

    protected override void handle(Socket client, ClientPausePacket packet)
    {
        received.emit(client, packet);
    }

    protected override void handle(Socket client, ClientContinuePacket packet)
    {
        received.emit(client, packet);
    }

    protected override void handle(Socket client, ClientExitPacket packet)
    {
        received.emit(client, packet);
    }

    protected override void handle(Socket client, ClientThreadPacket packet)
    {
        received.emit(client, packet);
    }

    protected override void handle(Socket client, ClientFramePacket packet)
    {
        received.emit(client, packet);
    }

    protected override void handle(Socket client, ClientBreakpointPacket packet)
    {
        received.emit(client, packet);
    }

    protected override void handle(Socket client, ClientCatchpointPacket packet)
    {
        received.emit(client, packet);
    }

    protected override void handle(Socket client, ClientDisassemblePacket packet)
    {
        received.emit(client, packet);
    }

    protected override void handle(Socket client, ClientInspectPacket packet)
    {
        received.emit(client, packet);
    }

    mixin Signal!Socket connected;
    mixin Signal!Socket disconnected;
    mixin Signal!(Socket, Packet) received;
}
