module mci.core.utilities;

import std.array;

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
