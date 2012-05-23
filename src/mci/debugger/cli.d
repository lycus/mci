module mci.debugger.cli;

import std.array,
       std.conv,
       std.socket,
       std.stdio,
       mci.debugger.client,
       mci.debugger.protocol;

/**
 * Represents the exit status of a command line debugger session.
 */
public enum DebuggerExitCode : ubyte
{
    success = 0, /// Execution finished successfully.
    failure = 1, /// An error occurred.
}

public final class CommandLineDebugger
{
    private SignalDebuggerClient _client;
    private ulong _threadID;
    private ulong _frameID;

    private void connected(Socket socket)
    in
    {
        assert(socket);
    }
    body
    {
        writefln("Connected to debugger server at: %s", socket.remoteAddress());
    }

    private void disconnected(Socket socket)
    in
    {
        assert(socket);
    }
    body
    {
        writefln("Disconnected from debugger server at: %s", socket.remoteAddress());
    }

    private void received(Socket socket, Packet packet)
    in
    {
        assert(socket);
        assert(packet);
    }
    body
    {
    }

    public DebuggerExitCode run()
    {
        bool stop;

        while (true)
        {
            write("(dbg) ");

            auto line = readln();
            auto words = split(line);

            if (!words)
                continue;

            auto cmd = words[0];
            auto args = words[1 .. $];

            switch (cmd)
            {
                case "c":
                case "connect":
                    if (args.length != 2)
                    {
                        writeln("No address/port given.");
                        break;
                    }

                    ushort port;

                    try
                        port = to!ushort(args[1]);
                    catch (ConvException)
                    {
                        writefln("Invalid port: '%s'", args[1]);
                        break;
                    }

                    Address addr;

                    try
                        addr = parseAddress(args[0], port);
                    catch (SocketException)
                    {
                        // Handled below.
                    }

                    if (!addr || (addr.addressFamily != AddressFamily.INET && addr.addressFamily != AddressFamily.INET6))
                    {
                        writefln("Invalid IPv4/IPv6 address: '%s'", args[0]);
                        break;
                    }

                    _client = new SignalDebuggerClient(addr);
                    _client.connected.connect(&connected);
                    _client.disconnected.connect(&disconnected);
                    _client.received.connect(&received);
                    _client.start();

                    break;
                case "d":
                case "disconnect":
                    if (!_client)
                    {
                        writeln("No active connection.");
                        break;
                    }

                    _client.stop();
                    _client = null;

                    break;
                case "i":
                case "info":
                case "query":
                    _client.send(new ClientQueryPacket());
                    break;
                case "s":
                case "start":
                    _client.send(new ClientStartPacket());
                    break;
                case "p":
                case "pause":
                    _client.send(new ClientPausePacket());
                    break;
                case "cont":
                case "continue":
                    _client.send(new ClientContinuePacket());
                    break;
                case "e":
                case "exit":
                    _client.send(new ClientExitPacket());
                    break;
                case "threads":
                    auto pkt = new ClientThreadPacket();
                    pkt.action = ThreadAction.list;

                    _client.send(pkt);
                    break;
                case "t":
                case "thread":
                    if (!args.length)
                    {
                        writefln("Current thread ID: %s", _threadID);
                        break;
                    }
                    else if (args.length == 1)
                    {
                        ulong id;

                        try
                            id = to!ulong(args[0]);
                        catch (ConvException)
                        {
                            writefln("Invalid thread ID: '%s'", args[0]);
                            break;
                        }

                        auto pkt = new ClientThreadPacket();
                        pkt.action = ThreadAction.switch_;
                        pkt.thread = id;

                        _client.send(pkt);
                    }
                    else
                        writeln("Invalid arguments.");

                    break;
                case "f":
                case "frame":
                    if (!args.length)
                    {
                        writefln("Current frame ID: %s", _frameID);
                        break;
                    }
                    else if (args.length == 1)
                    {
                        ulong id;

                        try
                            id = to!ulong(args[0]);
                        catch (ConvException)
                        {
                            writefln("Invalid frame ID: '%s'", args[0]);
                            break;
                        }

                        auto pkt = new ClientFramePacket();
                        pkt.frame = id;

                        _client.send(pkt);
                    }
                    else
                        writeln("Invalid arguments.");

                    break;
                case "q":
                case "quit":
                    stop = true;
                    break;
                default:
                    writefln("Unknown command: '%s'", cmd);
                    break;
            }

            if (stop)
            {
                if (_client)
                    _client.stop();

                break;
            }
        }

        return DebuggerExitCode.success;
    }
}
