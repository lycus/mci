module mci.debugger.server;

import core.thread,
       std.signals,
       std.socket,
       mci.core.atomic,
       mci.core.io,
       mci.core.nullable,
       mci.core.sync,
       mci.debugger.protocol,
       mci.debugger.utilities;

public alias void delegate() InterruptCallback;

public abstract class DebuggerServer
{
    private Atomic!bool _running;
    private Atomic!TcpSocket _socket;
    private Atomic!Thread _thread;
    private Atomic!Socket _client;
    private InterruptCallback _callback;
    private Atomic!bool _interrupt;
    private Mutex _interruptLock;
    private Mutex _interruptMutex;
    private Condition _interruptCondition;

    invariant()
    {
        if ((cast()_running).value)
        {
            assert((cast()_socket).value);
            assert((cast()_thread).value);
        }
        else
        {
            assert(!(cast()_socket).value);
            assert(!(cast()_thread).value);
            assert(!(cast()_client).value);
        }

        assert((cast()_interrupt).value ? !!_callback : !_callback);
        assert(_interruptLock);
        assert(_interruptMutex);
        assert(_interruptCondition);
    }

    protected this(Address address)
    in
    {
        assert(address);
        assert(address.addressFamily == AddressFamily.INET || address.addressFamily == AddressFamily.INET6);
    }
    body
    {
        _socket.value = new TcpSocket(address.addressFamily);
        _interruptLock = new typeof(_interruptLock)();
        _interruptMutex = new typeof(_interruptMutex)();
        _interruptCondition = new typeof(_interruptCondition)(_interruptMutex);

        _socket.value.bind(address);
    }

    public final void start()
    in
    {
        assert(!_running.value);
    }
    body
    {
        _running.value = true;
        _thread.value = new Thread(&run);

        _thread.value.start();
    }

    public final void stop()
    in
    {
        assert(_running.value);
    }
    body
    {
        _running.value = false;

        _thread.value.join();
        _thread.value = null;
    }

    private void run()
    {
        try
            _socket.value.listen(1);
        catch (SocketOSException)
        {
            kill();
            return;
        }

        try
            _client.value = _socket.value.accept();
        catch (SocketAcceptException)
        {
            kill();
            return;
        }

        _client.value.blocking = false;

        handleConnect(_client.value);

        while (_running.value)
        {
            auto buf = new ubyte[packetHeaderSize];

            // Read the header. This contains opcode, protocol version, and length.
            if (!receive(buf))
                break;

            auto br = new BinaryReader(new MemoryStream(buf, false));
            auto header = readHeader(br);

            br.stream.close();

            buf = new ubyte[header.z];

            // Next up, we fetch the body of the packet.
            if (header.z && !receive(buf))
                break;

            br = new BinaryReader(new MemoryStream(buf, false));

            // We can't use final switch. The thing is, the client could send a bad
            // opcode, so we need to handle that case gracefully.
            switch (cast(DebuggerClientOpCode)header.x)
            {
                case DebuggerClientOpCode.query:
                    auto pkt = new ClientQueryPacket();
                    pkt.read(br);
                    handle(_client.value, pkt);
                    break;
                case DebuggerClientOpCode.start:
                    auto pkt = new ClientStartPacket();
                    pkt.read(br);
                    handle(_client.value, pkt);
                    break;
                case DebuggerClientOpCode.pause:
                    auto pkt = new ClientPausePacket();
                    pkt.read(br);
                    handle(_client.value, pkt);
                    break;
                case DebuggerClientOpCode.continue_:
                    auto pkt = new ClientContinuePacket();
                    pkt.read(br);
                    handle(_client.value, pkt);
                    break;
                case DebuggerClientOpCode.exit:
                    auto pkt = new ClientExitPacket();
                    pkt.read(br);
                    handle(_client.value, pkt);
                    break;
                case DebuggerClientOpCode.thread:
                    auto pkt = new ClientThreadPacket();
                    pkt.read(br);
                    handle(_client.value, pkt);
                    break;
                case DebuggerClientOpCode.frame:
                    auto pkt = new ClientFramePacket();
                    pkt.read(br);
                    handle(_client.value, pkt);
                    break;
                case DebuggerClientOpCode.breakpoint:
                    auto pkt = new ClientBreakpointPacket();
                    pkt.read(br);
                    handle(_client.value, pkt);
                    break;
                case DebuggerClientOpCode.catchpoint:
                    auto pkt = new ClientCatchpointPacket();
                    pkt.read(br);
                    handle(_client.value, pkt);
                    break;
                case DebuggerClientOpCode.disassemble:
                    auto pkt = new ClientDisassemblePacket();
                    pkt.read(br);
                    handle(_client.value, pkt);
                    break;
                case DebuggerClientOpCode.inspect:
                    auto pkt = new ClientInspectPacket();
                    pkt.read(br);
                    handle(_client.value, pkt);
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
        _socket.value.shutdown(SocketShutdown.BOTH);
        _socket.value.close();
        _socket.value = null;

        if (_client.value)
        {
            handleDisconnect(_client.value);

            _client.value.shutdown(SocketShutdown.BOTH);
            _client.value.close();
            _client.value = null;
        }
    }

    public final void send(Packet packet)
    in
    {
        assert(packet);
        assert(_running.value);
    }
    body
    {
        auto stream = new MemoryStream(new ubyte[packetHeaderSize]);
        auto bw = new BinaryWriter(stream);

        stream.position = packetHeaderSize;

        packet.write(bw);

        stream.position = 0;

        writeHeader(bw, packet.opCode, protocolVersion, cast(uint)(stream.length - packetHeaderSize));

        while (true)
        {
            auto result = .send(_client.value, stream.data);

            if (!result.hasValue)
            {
                kill();
                return;
            }

            if (result.value == true)
                break;
        }

        stream.close();
    }

    private bool receive(ubyte[] buf)
    in
    {
        assert(buf);
    }
    body
    {
        while (true)
        {
            handleInterrupt();

            auto result = .receive(_client.value, buf);

            if (!result.hasValue)
                return false;

            if (result.value == true)
                return true;

            Thread.sleep(dur!("msecs")(20));
        }
    }

    private void handleInterrupt()
    {
        if (!_interrupt.value)
            return;

        _callback();

        _interrupt.value = false;
        _callback = null;

        _interruptMutex.lock();

        scope (exit)
            _interruptMutex.unlock();

        _interruptCondition.notifyAll();
    }

    public final void interrupt(InterruptCallback callback)
    in
    {
        assert(callback);
    }
    body
    {
        _interruptLock.lock();

        scope (exit)
            _interruptLock.unlock();

        _callback = callback;
        _interrupt.value = true;

        _interruptMutex.lock();

        scope (exit)
            _interruptMutex.unlock();

        _interruptCondition.wait();
    }

    protected void handleConnect(Socket socket)
    in
    {
        assert(socket);
    }
    body
    {
    }

    protected void handleDisconnect(Socket socket)
    in
    {
        assert(socket);
    }
    body
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
