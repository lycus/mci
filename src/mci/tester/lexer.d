module mci.tester.lexer;

import mci.assembler.parsing.lexer;

unittest
{
    auto source = new Source("abcdefghijklmnopqrstuvwxyz");

    assert(source.current == dchar.init);
    assert(source.location.line == 1);
    assert(source.location.column == 0);

    auto next = source.moveNext();

    assert(next == 'a');
    assert(source.current == 'a');
    assert(source.location.line == 1);
    assert(source.location.column == 1);
}

unittest
{
    auto source = new Source("abc\r\ndef\nghi\njkl");

    source.moveNext();
    source.moveNext();
    source.moveNext();
    source.moveNext();

    assert(source.current == '\r');
    assert(source.location.line == 1);
    assert(source.location.column == 4);

    source.moveNext();

    assert(source.current == '\n');
    assert(source.location.line == 2);
    assert(source.location.column == 1);
}
