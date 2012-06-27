module mci.debugger.client;

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

public abstract class DebuggerClient
{
    private Atomic!bool _running;
    private Address _address;
    private Atomic!TcpSocket _socket;
    private Atomic!Thread _thread;
    private Mutex _killMutex;
    private Mutex _interruptLock;
    private Mutex _interruptMutex;
    private Condition _interruptCondition;
    private InterruptCallback _callback;
    private Atomic!bool _interrupt;

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
        }

        assert(_address);
        assert(_killMutex);
        assert(_interruptLock);
        assert(_interruptMutex);
        assert(_interruptCondition);
        assert((cast()_interrupt).value ? !!_callback : !_callback);
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
        _killMutex = new typeof(_killMutex)();
        _interruptLock = new typeof(_interruptLock)();
        _interruptMutex = new typeof(_interruptMutex)();
        _interruptCondition = new typeof(_interruptCondition)(_interruptMutex);
    }

    @property public bool running() pure // TODO: Make this nothrow in 2.060.
    {
        return _running.value;
    }

    public final void start()
    in
    {
        assert(!_running.value);
    }
    body
    {
        _running.value = true;

        _socket.value = new TcpSocket(_address.addressFamily);
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

        kill();
        _thread.value.join();

        _thread.value = null;
    }

    private void run()
    {
        scope (exit)
            kill();

        try
            _socket.value.connect(_address);
        catch (SocketOSException)
            return;

        handleConnect(_socket.value);

        scope (exit)
            handleDisconnect(_socket.value);

        _socket.value.blocking = false;

        while (_running.value)
        {
            auto headerBuf = new ubyte[packetHeaderSize];

            // Read the header. This contains opcode, protocol version, and length.
            if (!receive(headerBuf))
                break;

            auto headerReader = new BinaryReader(new MemoryStream(headerBuf, false));
            auto header = readHeader(headerReader);

            headerReader.stream.close();

            auto packetBuf = new ubyte[header.z];

            // Next up, we fetch the body of the packet.
            if (header.z && !receive(packetBuf))
                break;

            auto packetReader = new BinaryReader(new MemoryStream(packetBuf, false));

            scope (exit)
                packetReader.stream.close();

            // We can't use final switch. The thing is, the server could send a bad
            // opcode, so we need to handle that case gracefully.
            switch (cast(DebuggerServerOpCode)header.x)
            {
                case DebuggerServerOpCode.result:
                    auto pkt = new ServerResultPacket();
                    pkt.read(packetReader);
                    handle(_socket.value, pkt);
                    break;
                case DebuggerServerOpCode.started:
                    auto pkt = new ServerStartedPacket();
                    pkt.read(packetReader);
                    handle(_socket.value, pkt);
                    break;
                case DebuggerServerOpCode.paused:
                    auto pkt = new ServerPausedPacket();
                    pkt.read(packetReader);
                    handle(_socket.value, pkt);
                    break;
                case DebuggerServerOpCode.continued:
                    auto pkt = new ServerContinuedPacket();
                    pkt.read(packetReader);
                    handle(_socket.value, pkt);
                    break;
                case DebuggerServerOpCode.exited:
                    auto pkt = new ServerExitedPacket();
                    pkt.read(packetReader);
                    handle(_socket.value, pkt);
                    break;
                case DebuggerServerOpCode.thread:
                    auto pkt = new ServerThreadPacket();
                    pkt.read(packetReader);
                    handle(_socket.value, pkt);
                    break;
                case DebuggerServerOpCode.frame:
                    auto pkt = new ServerFramePacket();
                    pkt.read(packetReader);
                    handle(_socket.value, pkt);
                    break;
                case DebuggerServerOpCode.break_:
                    auto pkt = new ServerBreakPacket();
                    pkt.read(packetReader);
                    handle(_socket.value, pkt);
                    break;
                case DebuggerServerOpCode.catch_:
                    auto pkt = new ServerCatchPacket();
                    pkt.read(packetReader);
                    handle(_socket.value, pkt);
                    break;
                case DebuggerServerOpCode.unhandled:
                    auto pkt = new ServerUnhandledPacket();
                    pkt.read(packetReader);
                    handle(_socket.value, pkt);
                    break;
                case DebuggerServerOpCode.disassembly:
                    auto pkt = new ServerDisassemblyPacket();
                    pkt.read(packetReader);
                    handle(_socket.value, pkt);
                    break;
                case DebuggerServerOpCode.values:
                    auto pkt = new ServerValuesPacket();
                    pkt.read(packetReader);
                    handle(_socket.value, pkt);
                    break;
                default:
                    return;
            }
        }
    }

    private void kill()
    {
        _killMutex.lock();

        scope (exit)
            _killMutex.unlock();

        if (_socket.value)
        {
            _socket.value.shutdown(SocketShutdown.BOTH);
            _socket.value.close();
            _socket.value = null;
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

        scope (exit)
            stream.close();

        auto bw = new BinaryWriter(stream);

        stream.position = packetHeaderSize;

        packet.write(bw);

        stream.position = 0;

        writeHeader(bw, packet.opCode, protocolVersion, cast(uint)(stream.length - packetHeaderSize));

        while (true)
        {
            auto result = .send(_socket.value, stream.data);

            if (!result.hasValue)
            {
                kill();
                return;
            }

            if (result.value == true)
                break;

            Thread.yield();
        }
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

            auto result = .receive(_socket.value, buf);

            if (!result.hasValue)
                return false;

            if (result.value == true)
                return true;

            Thread.sleep(dur!("msecs")(10));
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
