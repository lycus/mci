module mci.vm.io.table;

import mci.core.container;

package final class StringTable
{
    private Dictionary!(string, uint, false) _stringToID;
    private NoNullDictionary!(uint, string, false) _idToString;
    private uint _lastID;

    invariant()
    {
        assert(_stringToID);
        assert(_idToString);
    }

    public this()
    {
        _stringToID = new typeof(_stringToID)();
        _idToString = new typeof(_idToString)();
    }

    public void addPair(uint id, string value)
    in
    {
        assert(value);
    }
    body
    {
        _idToString.add(id, value);
        _stringToID.add(value, id);
    }

    public uint getID(string value)
    in
    {
        assert(value);
    }
    body
    {
        if (auto i = value in _stringToID)
            return *i;

        auto id = _lastID++;

        _stringToID.add(value, id);
        _idToString.add(id, value);

        return id;
    }

    public string getString(uint id)
    {
        if (auto str = id in _idToString)
            return *str;

        return null;
    }

    @property public Lookup!(uint, string) table() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _idToString;
    }
}
