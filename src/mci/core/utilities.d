module mci.core.utilities;

import std.array,
       std.conv,
       std.string;

/**
 * Escapes an identifier so it can be safely used in
 * IAL source code.
 *
 * Params:
 *  identifier = The identifier to escape.
 *
 * Returns:
 *  Escaped version of $(D identifier).
 */
public string escapeIdentifier(string identifier) // TODO: Make this pure nothrow.
{
    return "'" ~ replace(identifier, "'", "\\'") ~ "'";
}

// TODO: Replace this with xformat in 2.060.
public string format(Args ...)(string fmt, Args args)
in
{
    assert(fmt);
}
out (result)
{
    assert(result);
}
body
{
    return xformat(fmt, args);
}
