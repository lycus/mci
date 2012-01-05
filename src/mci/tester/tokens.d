module mci.tester.tokens;

import mci.core.container,
       mci.core.diagnostics.debugging,
       mci.assembler.parsing.tokens;

unittest
{
    auto list = new NoNullList!Token();

    list.add(new Token(TokenType.begin, null, new SourceLocation(1, 1)));
    list.add(new Token(TokenType.void_, "void", new SourceLocation(1, 1)));
    list.add(new Token(TokenType.constant, "const", new SourceLocation(1, 1)));
    list.add(new Token(TokenType.end, null, new SourceLocation(1, 1)));

    auto stream = new MemoryTokenStream(list);

    assert(stream.current.type == TokenType.begin);
    assert(stream.next.type == TokenType.void_);

    auto next = stream.moveNext();

    assert(next.type == TokenType.void_);
    assert(stream.previous.type == TokenType.begin);
    assert(stream.current.type == TokenType.void_);
    assert(stream.next.type == TokenType.constant);

    auto next2 = stream.moveNext();

    assert(next2.type == TokenType.constant);
    assert(stream.next.type == TokenType.end);
}
