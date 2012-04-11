module mci.tester.lexer;

import mci.assembler.parsing.lexer;

unittest
{
    enum string str = "abcdefghijklmnopqrstuvwxyz";

    auto source = new Source(str);

    assert(source.current == char.init);
    assert(source.peek(0) == char.init);
    assert(source.peek(1) == 'a');
    assert(source.peek(2) == 'b');

    source.moveNext();

    assert(source.current == 'a');
    assert(source.peek(0) == 'a');
    assert(source.peek(1) == 'b');
    assert(source.peek(2) == 'c');

    for (size_t i = 0; i < str.length - 1; i++)
        source.moveNext();

    assert(source.current == 'z');
    assert(source.peek(0) == 'z');
    assert(source.peek(1) == char.init);
}

unittest
{
    auto source = new Source("abcdefghijklmnopqrstuvwxyz");

    assert(source.current == char.init);
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
