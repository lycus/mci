module mci.vm.intrinsics.io;

import std.conv,
       std.stdio,
       mci.core.common,
       mci.core.io,
       mci.vm.intrinsics.memory;

public extern (C)
{
    File* mci_get_stdin()
    {
        return &stdin;
    }

    File* mci_get_stderr()
    {
        return &stderr;
    }

    File* mci_get_stdout()
    {
        return &stdout;
    }

    File* mci_file_open(ubyte* name, size_t length, FileAccess access, FileMode mode)
    {
        auto chrMode = accessAndModeToString(access, mode);
        auto mem = mci_memory_malloc(File.sizeof);
        auto file = emplace!File(cast(File*)mem, cast(string)name[0 .. length], chrMode);

        return file;
    }

    void mci_file_close(File* stream)
    {
        stream.close();
    }

    FILE* mci_file_fp(File* stream)
    {
        return stream.getFP();
    }

    bool mci_file_eof(File* stream)
    {
        return stream.eof;
    }

    bool mci_file_is_open(File* stream)
    {
        return stream.isOpen;
    }

    ulong mci_file_position(File* stream)
    {
        return stream.tell;
    }

    void mci_file_write(File* stream, ubyte* data, size_t length)
    {
        stream.rawWrite(data[0 .. length]);
    }

    void mci_file_write_line(File* stream, ubyte* data, size_t length)
    {
        mci_file_write(stream, data, length);
        stream.writeln();
    }

    ubyte* mci_file_read(File* stream, size_t length, size_t* result)
    {
        ubyte[] res;
        ubyte[1] buf;

        while (stream.rawRead(buf))
        {
            res ~= buf[0];
            (*result)++;
        }

        return copyToNative(res);
    }

    ubyte* mci_file_read_line(File* stream, size_t* result)
    {
        ubyte[] res;
        ubyte[1] buf;

        while (stream.rawRead(buf))
        {
            if (buf[0] == '\n')
                break;

            res ~= buf[0];
            (*result)++;
        }

        return copyToNative(res);
    }
}
