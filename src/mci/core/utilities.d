module mci.core.utilities;

import std.array;

public string escapeIdentifier(string identifier)
{
    return "'" ~ replace(identifier, "'", "\\'") ~ "'";
}
