module mci.tester.tokens;

import mci.core.container,
       mci.assembler.parsing.location,
       mci.assembler.parsing.tokens;

unittest
{
    auto list = new NoNullList!Token();

    list.add(new Token(TokenType.begin, null, SourceLocation(1, 1)));
    list.add(new Token(TokenType.void_, "void", SourceLocation(1, 1)));
    list.add(new Token(TokenType.static_, "const", SourceLocation(1, 1)));
    list.add(new Token(TokenType.end, null, SourceLocation(1, 1)));

    auto stream = new MemoryTokenStream(list);

    assert(stream.current.type == TokenType.begin);
    assert(stream.next.type == TokenType.void_);

    auto next = stream.moveNext();

    assert(next.type == TokenType.void_);
    assert(stream.previous.type == TokenType.begin);
    assert(stream.current.type == TokenType.void_);
    assert(stream.next.type == TokenType.static_);

    auto next2 = stream.moveNext();

    assert(next2.type == TokenType.static_);
    assert(stream.next.type == TokenType.end);
}
