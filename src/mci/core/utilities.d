module mci.core.utilities;

import std.array;

public string escapeIdentifier(string identifier) // TODO: Make this pure nothrow.
{
    return "'" ~ replace(identifier, "'", "\\'") ~ "'";
}
