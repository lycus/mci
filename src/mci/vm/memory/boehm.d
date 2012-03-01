module mci.vm.memory.boehm;

import core.stdc.string,
       std.conv,
       gc,
       mci.core.common,
       mci.core.config,
       mci.vm.memory.base,
       mci.vm.memory.info;

static if (operatingSystem != OperatingSystem.windows)
{
    public final class BoehmGarbageCollector : GarbageCollector
    {
        @property public ulong collections()
        {
            return GC_gc_no;
        }

        public RuntimeObject* allocate(RuntimeTypeInfo type, size_t extraSize = 0)
        {
            auto size = RuntimeObject.sizeof + type.size + extraSize;
            auto mem = GC_malloc(size);

            if (!mem)
                return null;

            // Zero memory, since libgc doesn't do it for us.
            memset(mem, 0, size);

            return emplace!RuntimeObject(mem[0 .. RuntimeObject.sizeof], type);
        }

        public void free(RuntimeObject* data)
        {
            if (!data)
                return;

            GC_free(data);
        }

        public void addRoot(ubyte* ptr)
        {
            GC_add_roots(ptr, ptr + size_t.sizeof + 1);
        }

        public void removeRoot(ubyte* ptr)
        {
            GC_remove_roots(ptr, ptr + size_t.sizeof + 1);
        }

        public void addRange(ubyte* ptr, size_t words)
        {
            GC_add_roots(ptr, ptr + size_t.sizeof * words + 1);
        }

        public void removeRange(ubyte* ptr, size_t words)
        {
            GC_remove_roots(ptr, ptr + size_t.sizeof * words + 1);
        }

        public size_t pin(RuntimeObject* data)
        {
            // Pinning is not supported in libgc.
            return 0;
        }

        public void unpin(size_t handle)
        {
            // Pinning is not supported in libgc.
        }

        public void collect()
        {
            GC_gcollect();
        }

        public void minimize()
        {
            // There's no support for minimization without stopping the world in libgc.
        }

        public void attach()
        {
            GC_stack_base sb;

            GC_get_stack_base(&sb);
            GC_register_my_thread(&sb);
        }

        public void detach()
        {
            GC_unregister_my_thread();
        }

        public void addPressure(size_t amount)
        {
        }

        public void removePressure(size_t amount)
        {
        }
    }
}
