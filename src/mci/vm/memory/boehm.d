module mci.vm.memory.boehm;

import core.stdc.string,
       std.conv,
       gc,
       mci.core.common,
       mci.core.container,
       mci.core.config,
       mci.core.typing.types,
       mci.vm.memory.base,
       mci.vm.memory.info;

static if (operatingSystem != OperatingSystem.windows)
{
    public final class BoehmGarbageCollector : GarbageCollector
    {
        private __gshared Dictionary!(RuntimeTypeInfo, size_t) _registeredBitmaps;

        shared static this()
        {
            _registeredBitmaps = new typeof(_registeredBitmaps)();
        }

        @property public ulong collections()
        {
            return GC_gc_no;
        }

        public RuntimeObject* allocate(RuntimeTypeInfo type, size_t extraSize = 0)
        {
            auto size = RuntimeObject.sizeof + type.size + extraSize;
            void* mem;

            if (tryCast!StructureType(type.type))
            {
                size_t descr;

                synchronized (_registeredBitmaps)
                {
                    if (auto d = type in _registeredBitmaps)
                        descr = *d;
                    else
                    {
                        auto words = new size_t[type.bitmap.count + (size_t.sizeof * 8 - 1) / size_t.sizeof * 8];

                        foreach (b; type.bitmap)
                            words ~= b;

                        descr = GC_make_descriptor(words.ptr, words.length);

                        _registeredBitmaps.add(type, descr);
                    }
                }

                mem = GC_malloc_explicitly_typed(size, descr);
            }
            else
                mem = GC_malloc(size);

            if (!mem)
                return null;

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
            GC_collect_a_little();
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
