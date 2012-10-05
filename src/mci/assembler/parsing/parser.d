module mci.assembler.parsing.parser;

import std.algorithm,
       std.conv,
       std.traits,
       mci.core.container,
       mci.core.nullable,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.opcodes,
       mci.core.typing.types,
       mci.assembler.exception,
       mci.assembler.parsing.ast,
       mci.assembler.parsing.exception,
       mci.assembler.parsing.location,
       mci.assembler.parsing.tokens;

/**
 * Represents a compilation unit (i.e. source file).
 */
public final class CompilationUnit
{
    private ReadOnlyIndexable!DeclarationNode _nodes;

    pure nothrow invariant()
    {
        assert(_nodes);
    }

    /**
     * Constructs a new $(D CompilationUnit) instance.
     *
     * Params:
     *  nodes = The AST nodes of this unit.
     */
    public this(NoNullList!DeclarationNode nodes)
    in
    {
        assert(nodes);
    }
    body
    {
        _nodes = nodes.duplicate();
    }

    /**
     * Gets the AST units making up this compilation unit.
     *
     * Returns:
     *  The AST nodes making up this compilation unit.
     */
    @property public ReadOnlyIndexable!DeclarationNode nodes() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _nodes;
    }
}

/**
 * The IAL (Intermediate Assembly Language) parser.
 */
public final class Parser
{
    private TokenStream _stream;

    pure nothrow invariant()
    {
        assert(_stream);
    }

    /**
     * Constructs a new $(D Parser) instance.
     *
     * Params:
     *  stream = The token stream to parse from.
     */
    public this(TokenStream stream) pure nothrow
    in
    {
        assert(stream);
    }
    body
    {
        _stream = stream;
    }

    /**
     * Gets the token stream associated with this parser.
     *
     * Returns:
     *  The token stream associated with this parser.
     */
    @property public TokenStream stream() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _stream;
    }

    private Token peek()
    in
    {
        assert(!_stream.done);
    }
    body
    {
        if (_stream.next.type == TokenType.end)
            errorGot("any token", _stream.current.location, "end of file", false);

        return _stream.next;
    }

    private Token peekEOF()
    in
    {
        assert(!_stream.done);
    }
    body
    {
        return _stream.next;
    }

    private Token next()
    in
    {
        assert(!_stream.done);
    }
    body
    {
        auto token = _stream.moveNext();

        // EOF not allowed.
        if (token.type == TokenType.end)
            errorGot("any token", token.location, "end of file", false);

        return token;
    }

    private Token nextEOF()
    in
    {
        assert(!_stream.done);
    }
    body
    {
        return _stream.moveNext();
    }

    private Token consume(string expect)
    in
    {
        assert(!_stream.done);
    }
    body
    {
        auto next = next();

        if (next.value != expect)
            errorGot("'" ~ expect ~ "'", next.location, next.value);

        return next;
    }

    private static void error(string error, SourceLocation location)
    in
    {
        assert(error);
    }
    body
    {
        throw new ParserException(error ~ ".", location);
    }

    private static void errorExpected(string expected, SourceLocation location)
    in
    {
        assert(expected);
    }
    body
    {
        throw new ParserException("Expected " ~ expected ~ ".", location);
    }

    private static void errorGot(T)(string expected, SourceLocation location, T got, bool quote = true)
    in
    {
        assert(expected);
    }
    body
    {
        auto s = to!string(got);

        if (quote)
            s = "'" ~ s ~ "'";

        throw new ParserException("Expected " ~ expected ~ ", but got " ~ s ~ ".", location);
    }

    /**
     * Parses a compilation unit from the token stream.
     *
     * Throws:
     *  $(D ParserException) if the parsing failed.
     *
     * Returns:
     *  The resulting parsed compilation unit.
     */
    public CompilationUnit parse()
    out (result)
    {
        assert(result);
    }
    body
    {
        _stream.reset();

        auto ast = new NoNullList!DeclarationNode();

        if (_stream.done)
            return new CompilationUnit(ast);

        auto token = Token.init;

        while ((token = peekEOF()).type != TokenType.end)
        {
            MetadataListNode metadata;

            if (token.type == TokenType.openBracket)
            {
                metadata = parseMetadataList();
                token = peek();
            }

            switch (token.type)
            {
                case TokenType.type:
                    ast.add(parseTypeDeclaration(metadata));
                    break;
                case TokenType.field:
                    ast.add(parseFieldDeclaration(metadata));
                    break;
                case TokenType.function_:
                    ast.add(parseFunctionDeclaration(metadata));
                    break;
                case TokenType.entry:
                    if (metadata)
                        error("entry points cannot have metadata", metadata.location);

                    ast.add(parseEntryPointDeclaration());
                    break;
                case TokenType.thread:
                    if (metadata)
                        error("entry points cannot have metadata", metadata.location);

                    ast.add(parseThreadEntryPointDeclaration());
                    break;
                case TokenType.module_:
                    if (metadata)
                        error("entry points cannot have metadata", metadata.location);

                    ast.add(parseModuleEntryPointDeclaration());
                    break;
                default:
                    errorGot("'type', 'field', 'function', 'entry', 'module', or 'thread'", token.location, token.value);
            }
        }

        return new CompilationUnit(ast);
    }

    private EntryPointDeclarationNode parseEntryPointDeclaration()
    out (result)
    {
        assert(result);
    }
    body
    {
        consume("entry");

        auto func = parseFunctionReference();

        consume(";");

        return new EntryPointDeclarationNode(func.location, func);
    }

    private EntryPointDeclarationNode parseModuleEntryPointDeclaration()
    out (result)
    {
        assert(result);
    }
    body
    {
        consume("module");

        bool isEntry;

        auto tok = next();

        switch (tok.type)
        {
            case TokenType.entry:
                isEntry = true;
                break;
            case TokenType.exit:
                break;
            default:
                errorGot("'entry' or 'exit'", tok.location, tok.value);
                break;
        }

        auto func = parseFunctionReference();

        consume(";");

        if (isEntry)
            return new ModuleEntryPointDeclarationNode(func.location, func);
        else
            return new ModuleExitPointDeclarationNode(func.location, func);
    }

    private EntryPointDeclarationNode parseThreadEntryPointDeclaration()
    out (result)
    {
        assert(result);
    }
    body
    {
        consume("thread");

        bool isEntry;

        auto tok = next();

        switch (tok.type)
        {
            case TokenType.entry:
                isEntry = true;
                break;
            case TokenType.exit:
                break;
            default:
                errorGot("'entry' or 'exit'", tok.location, tok.value);
                break;
        }

        auto func = parseFunctionReference();

        consume(";");

        if (isEntry)
            return new ThreadEntryPointDeclarationNode(func.location, func);
        else
            return new ThreadExitPointDeclarationNode(func.location, func);
    }

    private TypeDeclarationNode parseTypeDeclaration(MetadataListNode metadata)
    out (result)
    {
        assert(result);
    }
    body
    {
        consume("type");

        auto name = parseSimpleName();

        LiteralValueNode alignment;

        if (peek().type == TokenType.align_)
        {
            next();
            alignment = parseLiteralValue!uint();
        }

        consume("{");

        auto members = new NoNullList!MemberDeclarationNode();
        auto token = Token.init;

        while ((token = peek()).type != TokenType.closeBrace)
        {
            if (token.type == TokenType.field)
                members.add(parseMemberDeclaration());
            else
                errorGot("'field'", token.location, token.value);
        }

        consume("}");

        return new TypeDeclarationNode(name.location, name, alignment, members, metadata);
    }

    private ModuleReferenceNode parseModuleReference()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = parseSimpleName();

        return new ModuleReferenceNode(name.location, name);
    }

    private FunctionPointerTypeReferenceNode parseFunctionPointerTypeReference(TypeReferenceNode returnType)
    out (result)
    {
        assert(result);
    }
    body
    {
        auto paren = consume("(");

        auto params = new NoNullList!TypeReferenceNode();

        while (peek().type != TokenType.closeParen)
        {
            params.add(parseTypeSpecification());

            if (peek().type != TokenType.closeParen)
            {
                consume(",");

                auto closeParen = peek();

                if (closeParen.type == TokenType.closeParen)
                    errorGot("type specification", closeParen.location, closeParen.value);
            }
        }

        next();

        CallingConvention cc;

        auto ccTok = peek();

        switch (ccTok.type)
        {
            case TokenType.cdecl:
                next();
                cc = CallingConvention.cdecl;
                break;
            case TokenType.stdCall:
                next();
                cc = CallingConvention.stdCall;
                break;
            default:
                break;
        }

        return new FunctionPointerTypeReferenceNode(paren.location, cc, returnType, params);
    }

    private TypeReferenceNode parseTypeSpecification()
    out (result)
    {
        assert(result);
    }
    body
    {
        if (peek().type == TokenType.void_)
        {
            next();
            return parseFunctionPointerTypeReference(null);
        }

        auto type = parseTypeReference();

        while (true)
        {
            auto peekVal = peek();

            switch (peekVal.type)
            {
                case TokenType.star:
                    next();
                    type = new PointerTypeReferenceNode(type.location, type);

                    break;
                case TokenType.openBracket:
                    next();

                    if (peek().type == TokenType.literal)
                    {
                        auto elements = parseLiteralValue!uint();

                        type = new VectorTypeReferenceNode(type.location, type, elements);
                    }
                    else
                        type = new ArrayTypeReferenceNode(type.location, type);

                    consume("]");

                    break;
                case TokenType.openBrace:
                    next();

                    auto elements = parseLiteralValue!uint();

                    type = new StaticArrayTypeReferenceNode(type.location, type, elements);

                    consume("}");

                    break;
                case TokenType.openParen:
                    type = parseFunctionPointerTypeReference(type);
                    break;
                default:
                    return type;
            }
        }

        assert(false);
    }

    private TypeReferenceNode parseStructureTypeSpecification()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto node = parseStructureTypeReference();

        if (peek().type == TokenType.and)
        {
            next();
            return new ReferenceTypeReferenceNode(node.location, node);
        }

        return node;
    }

    private StructureTypeReferenceNode parseStructureTypeReference()
    out (result)
    {
        assert(result);
    }
    body
    {
        next();

        ModuleReferenceNode moduleName;

        if (peek().type == TokenType.slash)
        {
            _stream.movePrevious();
            moduleName = parseModuleReference();
            next();
        }
        else
            _stream.movePrevious();

        auto name = parseSimpleName();

        return new StructureTypeReferenceNode(name.location, moduleName, name);
    }

    private TypeReferenceNode parseTypeReference()
    out (result)
    {
        assert(result);
    }
    body
    {
        // We could just peek here and avoid the movePrevious call,
        // but it would result in having to call next in all the
        // cases below.
        auto tok = next();

        switch (tok.type)
        {
            case TokenType.int8:
                return new Int8TypeReferenceNode(tok.location);
            case TokenType.uint8:
                return new UInt8TypeReferenceNode(tok.location);
            case TokenType.int16:
                return new Int16TypeReferenceNode(tok.location);
            case TokenType.uint16:
                return new UInt16TypeReferenceNode(tok.location);
            case TokenType.int32:
                return new Int32TypeReferenceNode(tok.location);
            case TokenType.uint32:
                return new UInt32TypeReferenceNode(tok.location);
            case TokenType.int64:
                return new Int64TypeReferenceNode(tok.location);
            case TokenType.uint64:
                return new UInt64TypeReferenceNode(tok.location);
            case TokenType.int_:
                return new NativeIntTypeReferenceNode(tok.location);
            case TokenType.uint_:
                return new NativeUIntTypeReferenceNode(tok.location);
            case TokenType.float32:
                return new Float32TypeReferenceNode(tok.location);
            case TokenType.float64:
                return new Float64TypeReferenceNode(tok.location);
            default:
                _stream.movePrevious();
                return parseStructureTypeSpecification();
        }
    }

    private MemberReferenceNode parseMemberReference()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto type = parseStructureTypeReference();

        consume(":");

        auto name = parseSimpleName();

        return new MemberReferenceNode(name.location, type, name);
    }

    private GlobalFieldReferenceNode parseGlobalFieldReference()
    out (result)
    {
        assert(result);
    }
    body
    {
        next();

        ModuleReferenceNode moduleName;

        if (peek().type == TokenType.slash)
        {
            _stream.movePrevious();
            moduleName = parseModuleReference();
            next();
        }
        else
            _stream.movePrevious();

        auto name = parseSimpleName();

        return new GlobalFieldReferenceNode(name.location, moduleName, name);
    }

    private ThreadFieldReferenceNode parseThreadFieldReference()
    out (result)
    {
        assert(result);
    }
    body
    {
        next();

        ModuleReferenceNode moduleName;

        if (peek().type == TokenType.slash)
        {
            _stream.movePrevious();
            moduleName = parseModuleReference();
            next();
        }
        else
            _stream.movePrevious();

        auto name = parseSimpleName();

        return new ThreadFieldReferenceNode(name.location, moduleName, name);
    }

    private FunctionReferenceNode parseFunctionReference()
    out (result)
    {
        assert(result);
    }
    body
    {
        next();

        ModuleReferenceNode moduleName;

        if (peek().type == TokenType.slash)
        {
            _stream.movePrevious();
            moduleName = parseModuleReference();
            next();
        }
        else
            _stream.movePrevious();

        auto name = parseSimpleName();

        return new FunctionReferenceNode(name.location, moduleName, name);
    }

    private MemberDeclarationNode parseMemberDeclaration()
    out (result)
    {
        assert(result);
    }
    body
    {
        consume("field");

        auto type = parseTypeSpecification();
        auto name = parseSimpleName();

        consume(";");

        return new MemberDeclarationNode(_stream.previous.location, type, name);
    }

    private LiteralValueNode parseLiteralValue(T)()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto literal = parseAnyLiteralValue();
        string value;
        uint radix;

        if (startsWith(literal.value, "0x"))
        {
            value = literal.value[2 .. $];
            radix = 16;
        }
        else
        {
            value = literal.value;
            radix = 10;
        }

        try
        {
            static if (!isFloatingPoint!T)
                .parse!T(value, radix);
            else
                .parse!T(value);
        }
        catch (ConvException)
            error("invalid " ~ T.stringof ~ " literal", literal.location);

        if (value.length)
            error("could not lex literal completely as " ~ T.stringof, literal.location);

        return literal;
    }

    private LiteralValueNode parseAnyLiteralValue()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto literal = next();

        if (literal.type != TokenType.literal)
            errorGot("literal value", literal.location, literal.value);

        return new LiteralValueNode(literal.location, literal.value);
    }

    private SimpleNameNode parseSimpleName()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = next();

        if (name.type != TokenType.identifier)
            errorGot("simple name", name.location, name.value);

        return new SimpleNameNode(name.location, name.value);
    }

    private MetadataNode parseMetadata()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto key = parseSimpleName();

        consume(":");

        auto value = parseSimpleName();

        return new MetadataNode(key.location, key, value);
    }

    private MetadataListNode parseMetadataList()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto open = consume("[");

        auto metadata = new NoNullList!MetadataNode();

        while (peek().type != TokenType.closeBracket)
        {
            metadata.add(parseMetadata());

            if (peek().type != TokenType.closeBracket)
            {
                consume(",");

                auto closeBracket = peek();

                if (closeBracket.type == TokenType.closeBracket)
                    errorGot("metadata pair", closeBracket.location, closeBracket.value);
            }
        }

        next();

        return new MetadataListNode(open.location, metadata);
    }

    private FieldDeclarationNode parseFieldDeclaration(MetadataListNode metadata)
    out (result)
    {
        assert(result);
    }
    body
    {
        consume("field");

        auto tok = peek();
        bool isGlobal;

        if (tok.type == TokenType.global)
            isGlobal = true;
        else if (tok.type != TokenType.thread)
            errorGot("'global' or 'thread'", tok.location, tok.value);

        next();

        auto type = parseTypeSpecification();
        auto name = parseSimpleName();

        consume(";");

        if (isGlobal)
            return new GlobalFieldDeclarationNode(name.location, name, type, metadata);
        else
            return new ThreadFieldDeclarationNode(name.location, name, type, metadata);
    }

    private FunctionDeclarationNode parseFunctionDeclaration(MetadataListNode metadata)
    out (result)
    {
        assert(result);
    }
    body
    {
        consume("function");

        FunctionAttributes attributes;

        if (peek().type == TokenType.ssa)
        {
            next();
            attributes |= FunctionAttributes.ssa;
        }

        if (peek().type == TokenType.pure_)
        {
            next();
            attributes |= FunctionAttributes.pure_;
        }

        if (peek().type == TokenType.noOptimization)
        {
            next();
            attributes |= FunctionAttributes.noOptimization;
        }

        if (peek().type == TokenType.noInlining)
        {
            next();
            attributes |= FunctionAttributes.noInlining;
        }

        if (peek().type == TokenType.noReturn)
        {
            next();
            attributes |= FunctionAttributes.noReturn;
        }

        if (peek().type == TokenType.noThrow)
        {
            next();
            attributes |= FunctionAttributes.noThrow;
        }

        TypeReferenceNode returnType;

        auto voidTok = next();

        if (voidTok.type != TokenType.void_)
        {
            _stream.movePrevious();
            returnType = parseTypeSpecification();
        }
        else
        {
            if (peek().type != TokenType.identifier)
            {
                _stream.movePrevious();
                returnType = parseTypeSpecification();
            }
        }

        auto name = parseSimpleName();

        consume("(");

        auto params = new NoNullList!ParameterNode();

        while (peek().type != TokenType.closeParen)
        {
            MetadataListNode paramMetadata;

            if (peek().type == TokenType.openBracket)
                paramMetadata = parseMetadataList();

            ParameterAttributes paramAttr;

            if (peek().type == TokenType.noEscape)
            {
                next();
                paramAttr |= ParameterAttributes.noEscape;
            }

            auto paramType = parseTypeSpecification();

            params.add(new ParameterNode(paramType.location, paramType, paramAttr, paramMetadata));

            if (peek().type != TokenType.closeParen)
            {
                consume(",");

                auto closeParen = peek();

                if (closeParen.type == TokenType.closeParen)
                    errorGot("type specification", closeParen.location, closeParen.value);
            }
        }

        next();

        CallingConvention cc;

        auto ccTok = peek();

        switch (ccTok.type)
        {
            case TokenType.cdecl:
                next();
                cc = CallingConvention.cdecl;
                break;
            case TokenType.stdCall:
                next();
                cc = CallingConvention.stdCall;
                break;
            default:
                break;
        }

        consume("{");

        auto registers = new NoNullList!RegisterDeclarationNode();
        auto blocks = new NoNullList!BasicBlockDeclarationNode();
        auto tok = Token.init;

        while ((tok = peek()).type != TokenType.closeBrace)
        {
            switch (tok.type)
            {
                case TokenType.register:
                    registers.add(parseRegisterDeclaration());
                    break;
                case TokenType.block:
                    blocks.add(parseBasicBlockDeclaration());
                    break;
                default:
                    errorGot("'register' or 'block'", tok.location, tok.value);
            }
        }

        next();

        return new FunctionDeclarationNode(name.location, name, cc, attributes, params, returnType, registers, blocks, metadata);
    }

    private RegisterDeclarationNode parseRegisterDeclaration()
    out (result)
    {
        assert(result);
    }
    body
    {
        MetadataListNode metadata;

        if (peek().type == TokenType.openBracket)
            metadata = parseMetadataList();

        consume("register");

        auto type = parseTypeSpecification();
        auto name = parseSimpleName();

        consume(";");

        return new RegisterDeclarationNode(name.location, name, type, metadata);
    }

    private BasicBlockDeclarationNode parseBasicBlockDeclaration()
    out (result)
    {
        assert(result);
    }
    body
    {
        MetadataListNode metadata;

        if (peek().type == TokenType.openBracket)
            metadata = parseMetadataList();

        consume("block");

        SimpleNameNode name;

        if (peek().type == TokenType.entry)
        {
            auto entry = next();
            name = new SimpleNameNode(entry.location, entry.value);
        }
        else
            name = parseSimpleName();

        BasicBlockReferenceNode unwind;

        if (peek().type == TokenType.unwind)
        {
            next();
            unwind = parseBasicBlockReference();
        }

        consume("{");

        auto instructions = new NoNullList!InstructionNode();
        auto tok = Token.init;

        while ((tok = peek()).type != TokenType.closeBrace)
            instructions.add(parseInstruction());

        next();

        return new BasicBlockDeclarationNode(name.location, name, unwind, instructions, metadata);
    }

    private InstructionNode parseInstruction()
    out (result)
    {
        assert(result);
    }
    body
    {
        MetadataListNode metadata;

        if (peek().type == TokenType.openBracket)
            metadata = parseMetadataList();

        InstructionAttributes attributes;

        if (peek().type == TokenType.volatile_)
        {
            next();
            attributes |= InstructionAttributes.volatile_;
        }

        RegisterReferenceNode target;

        next();

        if (peek().type == TokenType.equals)
        {
            _stream.movePrevious();
            target = parseRegisterReference();
            next();
        }
        else
            _stream.movePrevious();

        auto opCodeTok = next();

        if (opCodeTok.type != TokenType.opCode)
            errorGot("any valid opcode", opCodeTok.location, opCodeTok.value);

        OpCode opCode;

        // If the lexer returns a token with TokenType.opCode, that means
        // that the opcode actually exists, so opCode will not be null after
        // this loop.
        foreach (op; allOpCodes)
            if (op.name == opCodeTok.value)
                opCode = op;

        if (!target && opCode.hasTarget)
            error("Opcode '" ~ opCode.name ~ "' expects a target register", opCodeTok.location);
        else if (target && !opCode.hasTarget)
            error("Opcode '" ~ opCode.name ~ "' does not expect a target register", target.location);

        RegisterReferenceNode source1;
        RegisterReferenceNode source2;
        RegisterReferenceNode source3;

        if (opCode.registers >= 1)
            source1 = parseRegisterReference();

        if (opCode.registers >= 2)
        {
            consume(",");
            source2 = parseRegisterReference();
        }

        if (opCode.registers >= 3)
        {
            consume(",");
            source3 = parseRegisterReference();
        }

        InstructionOperandNode operand;

        auto operandType = opCode.operandType;

        if (operandType != OperandType.none)
        {
            consume("(");

            // If we're parsing a byte array, register selector, or foreign function,
            // bring the opening parenthesis back in. This is hacky, but it makes
            // parsing easier.
            if (isArrayOperand(operandType) || operandType == OperandType.selector)
                _stream.movePrevious();

            operand = parseInstructionOperand(operandType);

            if (!isArrayOperand(operandType) && operandType != OperandType.selector)
                consume(")");
        }

        consume(";");

        return new InstructionNode(opCodeTok.location, opCode, attributes, target, source1, source2,
                                   source3, operand, metadata);
    }

    private InstructionOperandNode parseInstructionOperand(OperandType operandType)
    out (result)
    {
        assert(result);
    }
    body
    {
        mci.assembler.parsing.ast.InstructionOperand operand;
        SourceLocation location;

        final switch (operandType)
        {
            case OperandType.none:
                assert(false);
            case OperandType.int8:
                auto literal = parseLiteralValue!byte();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.uint8:
                auto literal = parseLiteralValue!ubyte();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.int16:
                auto literal = parseLiteralValue!short();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.uint16:
                auto literal = parseLiteralValue!ushort();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.int32:
                auto literal = parseLiteralValue!int();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.uint32:
                auto literal = parseLiteralValue!uint();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.int64:
                auto literal = parseLiteralValue!long();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.uint64:
                auto literal = parseLiteralValue!ulong();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.float32:
                auto literal = parseLiteralValue!float();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.float64:
                auto literal = parseLiteralValue!double();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.int8Array:
                auto literal = parseArrayLiteral!byte();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.uint8Array:
                auto literal = parseArrayLiteral!ubyte();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.int16Array:
                auto literal = parseArrayLiteral!short();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.uint16Array:
                auto literal = parseArrayLiteral!ushort();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.int32Array:
                auto literal = parseArrayLiteral!int();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.uint32Array:
                auto literal = parseArrayLiteral!uint();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.int64Array:
                auto literal = parseArrayLiteral!long();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.uint64Array:
                auto literal = parseArrayLiteral!ulong();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.float32Array:
                auto literal = parseArrayLiteral!float();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.float64Array:
                auto literal = parseArrayLiteral!double();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.label:
                auto block = parseBasicBlockReference();
                operand = block;
                location = block.location;
                break;
            case OperandType.branch:
                auto branch = parseBranchSelector();
                operand = branch;
                location = branch.location;
                break;
            case OperandType.type:
                auto type = parseTypeSpecification();
                operand = type;
                location = type.location;
                break;
            case OperandType.member:
                auto field = parseMemberReference();
                operand = field;
                location = field.location;
                break;
            case OperandType.globalField:
                auto field = parseGlobalFieldReference();
                operand = field;
                location = field.location;
                break;
            case OperandType.threadField:
                auto field = parseThreadFieldReference();
                operand = field;
                location = field.location;
                break;
            case OperandType.function_:
                auto method = parseFunctionReference();
                operand = method;
                location = method.location;
                break;
            case OperandType.selector:
                auto selector = parseRegisterSelector();
                operand = selector;
                location = selector.location;
                break;
            case OperandType.foreignFunction:
                auto signature = parseForeignFunction();
                operand = signature;
                location = signature.location;
                break;
        }

        return new InstructionOperandNode(location, operand);
    }

    private RegisterSelectorNode parseRegisterSelector()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto open = consume("(");

        auto registers = new NoNullList!RegisterReferenceNode();

        while (peek().type != TokenType.closeParen)
        {
            registers.add(parseRegisterReference());

            if (peek().type != TokenType.closeParen)
            {
                consume(",");

                auto closeParen = peek();

                if (closeParen.type == TokenType.closeParen)
                    errorGot("register reference", closeParen.location, closeParen.value);
            }
        }

        consume(")");

        return new RegisterSelectorNode(open.location, registers);
    }

    private RegisterReferenceNode parseRegisterReference()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = parseSimpleName();

        return new RegisterReferenceNode(name.location, name);
    }

    private BasicBlockReferenceNode parseBasicBlockReference()
    out (result)
    {
        assert(result);
    }
    body
    {

        SimpleNameNode name;

        if (peek().type == TokenType.entry)
        {
            auto entry = next();
            name = new SimpleNameNode(entry.location, entry.value);
        }
        else
            name = parseSimpleName();

        return new BasicBlockReferenceNode(name.location, name);
    }

    private BranchSelectorNode parseBranchSelector()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto trueBB = parseBasicBlockReference();

        consume(",");

        auto falseBB = parseBasicBlockReference();

        return new BranchSelectorNode(trueBB.location, trueBB, falseBB);
    }

    private ArrayLiteralNode parseArrayLiteral(T)()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto open = consume("(");

        auto values = new NoNullList!LiteralValueNode();

        while (peek().type != TokenType.closeParen)
        {
            values.add(parseLiteralValue!T());

            if (peek().type != TokenType.closeParen)
            {
                consume(",");

                auto closeParen = peek();

                if (closeParen.type == TokenType.closeParen)
                    errorGot("literal value", closeParen.location, closeParen.value);
            }
        }

        next();

        return new ArrayLiteralNode(open.location, values);
    }

    private ForeignFunctionNode parseForeignFunction()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto library = parseSimpleName();

        consume(",");

        auto ep = parseSimpleName();

        return new ForeignFunctionNode(library.location, library, ep);
    }
}
