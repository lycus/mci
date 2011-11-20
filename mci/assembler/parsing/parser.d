module mci.assembler.parsing.parser;

import std.conv,
       std.string,
       mci.core.container,
       mci.core.nullable,
       mci.core.code.functions,
       mci.core.code.opcodes,
       mci.core.diagnostics.debugging,
       mci.core.typing.members,
       mci.core.typing.types,
       mci.assembler.exception,
       mci.assembler.parsing.ast,
       mci.assembler.parsing.exception,
       mci.assembler.parsing.tokens;

public final class CompilationUnit
{
    private NoNullList!DeclarationNode _nodes;

    invariant()
    {
        assert(_nodes);
    }

    public this(NoNullList!DeclarationNode nodes)
    in
    {
        assert(nodes);
    }
    body
    {
        _nodes = nodes.duplicate();
    }

    @property public Countable!DeclarationNode nodes()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _nodes;
    }
}

public final class Parser
{
    private TokenStream _stream;

    invariant()
    {
        assert(_stream);
    }

    public this(TokenStream stream)
    in
    {
        assert(stream);
    }
    body
    {
        _stream = stream;
    }

    private Token peek()
    in
    {
        assert(!_stream.done);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        if (_stream.next.type == TokenType.end)
            errorGot("any token", _stream.current.location, "end of file");

        return _stream.next;
    }

    private Token peekEof()
    in
    {
        assert(!_stream.done);
    }
    out (result)
    {
        assert(result);
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
    out (result)
    {
        assert(result);
    }
    body
    {
        auto token = _stream.moveNext();

        // EOF not allowed.
        if (token.type == TokenType.end)
            errorGot("any token", token.location, "end of file");

        return token;
    }

    private Token nextEof()
    in
    {
        assert(!_stream.done);
    }
    out (result)
    {
        assert(result);
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
    out (result)
    {
        assert(result);
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
        assert(location);
    }
    body
    {
        throw new ParserException(error ~ ".", location);
    }

    private static void errorExpected(string expected, SourceLocation location)
    in
    {
        assert(expected);
        assert(location);
    }
    body
    {
        throw new ParserException("Expected " ~ expected ~ ".", location);
    }

    private static void errorGot(T)(string expected, SourceLocation location, T got)
    in
    {
        assert(expected);
        assert(location);
    }
    body
    {
        throw new ParserException("Expected " ~ expected ~ ", but got '" ~ to!string(got) ~ "'.", location);
    }

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

        Token token;

        while ((token = peekEof()).type != TokenType.end)
        {
            switch (token.type)
            {
                case TokenType.type:
                    ast.add(parseTypeDeclaration());
                    break;
                case TokenType.function_:
                    ast.add(parseFunctionDeclaration());
                    break;
                default:
                    errorGot("'type' or 'function'", token.location, token.value);
            }
        }

        return new CompilationUnit(ast);
    }

    private TypeDeclarationNode parseTypeDeclaration()
    out (result)
    {
        assert(result);
    }
    body
    {
        consume("type");

        TypeLayout layout;

        auto layoutTok = next();

        switch (layoutTok.type)
        {
            case TokenType.automatic:
                layout = TypeLayout.automatic;
                break;
            case TokenType.sequential:
                layout = TypeLayout.sequential;
                break;
            case TokenType.explicit:
                layout = TypeLayout.explicit;
                break;
            default:
                errorGot("'automatic', 'sequential', or 'explicit'", layoutTok.location, layoutTok.value);
        }

        auto name = parseSimpleName();

        consume("{");

        auto fields = new NoNullList!FieldDeclarationNode();

        Token token;

        while ((token = peek()).type != TokenType.closeBrace)
        {
            if (token.type == TokenType.field)
                fields.add(parseFieldDeclaration());
            else
                errorGot("'field'", token.location, token.value);
        }

        consume("}");

        return new TypeDeclarationNode(name.location, name, layout, fields);
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

    private FunctionPointerTypeReferenceNode parseFunctionPointerTypeReference()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto returnType = parseTypeSpecification(true);

        consume("(");

        auto params = new NoNullList!TypeReferenceNode();

        while (peek().type != TokenType.closeParen)
        {
            params.add(parseTypeSpecification());

            if (peek().type != TokenType.closeParen)
            {
                consume(",");

                if (peek().type == TokenType.closeParen)
                    errorGot("type specification", peek.location, peek.value);
            }
        }

        next();

        return new FunctionPointerTypeReferenceNode(returnType.location, returnType, params);
    }

    private TypeReferenceNode parseTypeSpecification(bool insideFunctionPointer = false)
    out (result)
    {
        assert(result);
    }
    body
    {
        auto type = parseTypeReference();

        // Handle function pointer types.
        if (!insideFunctionPointer && peek().type == TokenType.openParen)
        {
            _stream.movePrevious();
            return parseFunctionPointerTypeReference();
        }

        while (peek().type == TokenType.star)
        {
            next();
            type = new PointerTypeReferenceNode(type.location, type);
        }

        return type;
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
            case TokenType.unit:
                return new UnitTypeReferenceNode(tok.location);
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
                return parseStructureTypeReference();
        }
    }

    private FieldReferenceNode parseFieldReference()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto type = parseStructureTypeReference();

        consume(":");

        auto name = parseSimpleName();

        return new FieldReferenceNode(name.location, type, name);
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

    private FieldDeclarationNode parseFieldDeclaration()
    out (result)
    {
        assert(result);
    }
    body
    {
        consume("field");

        FieldStorage storage;

        auto storageTok = next();

        switch (storageTok.type)
        {
            case TokenType.instance:
                storage = FieldStorage.instance;
                break;
            case TokenType.static_:
                storage = FieldStorage.static_;
                break;
            case TokenType.constant:
                storage = FieldStorage.constant;
                break;
            default:
                errorGot("'instance', 'static', or 'const'", storageTok.location, storageTok.value);
                break;
        }

        auto type = parseTypeSpecification();
        auto name = parseSimpleName();

        LiteralValueNode offset;

        if (peek().type == TokenType.openParen)
        {
            next();

            offset = parseLiteralValue!uint();

            consume(")");
        }

        consume(";");

        return new FieldDeclarationNode(_stream.previous.location, type, name, storage, offset);
    }

    private LiteralValueNode parseLiteralValue(T)()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto literal = parseAnyLiteralValue();

        try
        {
            to!T(literal.value);
        }
        catch (ConvOverflowException)
        {
            error(T.stringof ~ " literal overflow", literal.location);
        }
        catch (ConvException)
        {
            error("invalid " ~ T.stringof ~ " literal", literal.location);
        }

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

    private FunctionDeclarationNode parseFunctionDeclaration()
    out (result)
    {
        assert(result);
    }
    body
    {
        consume("function");

        FunctionAttributes attributes;

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

        if (peek().type == TokenType.noCallInlining)
        {
            next();
            attributes |= FunctionAttributes.noCallInlining;
        }

        CallingConvention callConv;

        auto convTok = next();

        switch (convTok.type)
        {
            case TokenType.queueCall:
                callConv = CallingConvention.queueCall;
                break;
            case TokenType.cdecl:
                callConv = CallingConvention.cdecl;
                break;
            case TokenType.stdCall:
                callConv = CallingConvention.stdCall;
                break;
            case TokenType.thisCall:
                callConv = CallingConvention.thisCall;
                break;
            case TokenType.fastCall:
                callConv = CallingConvention.fastCall;
                break;
            default:
                errorGot("'qcall', 'ccall', 'scall', 'tcall', or 'fcall'", convTok.location, convTok.value);
        }

        auto returnType = parseTypeSpecification();
        auto name = parseSimpleName();

        consume("(");

        auto params = new NoNullList!ParameterNode();

        while (peek().type != TokenType.closeParen)
        {
            auto paramType = parseTypeSpecification();

            params.add(new ParameterNode(paramType.location, paramType));

            if (peek().type != TokenType.closeParen)
            {
                consume(",");

                if (peek().type == TokenType.closeParen)
                    errorGot("type specification", peek.location, peek.value);
            }
        }

        next();
        consume("{");

        auto registers = new NoNullList!RegisterDeclarationNode();
        auto blocks = new NoNullList!BasicBlockDeclarationNode();

        Token tok;

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

        return new FunctionDeclarationNode(name.location, name, attributes, callConv, params,
                                           returnType, registers, blocks);
    }

    private RegisterDeclarationNode parseRegisterDeclaration()
    out (result)
    {
        assert(result);
    }
    body
    {
        consume("register");

        auto type = parseTypeSpecification();
        auto name = parseSimpleName();

        consume(";");

        return new RegisterDeclarationNode(name.location, name, type);
    }

    private BasicBlockDeclarationNode parseBasicBlockDeclaration()
    out (result)
    {
        assert(result);
    }
    body
    {
        consume("block");

        auto name = parseSimpleName();

        consume("{");

        auto instructions = new NoNullList!InstructionNode();

        Token tok;

        while ((tok = peek()).type != TokenType.closeBrace)
            instructions.add(parseInstruction());

        next();

        return new BasicBlockDeclarationNode(name.location, name, instructions);
    }

    private InstructionNode parseInstruction()
    out (result)
    {
        assert(result);
    }
    body
    {
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

        if (target is null && opCode.hasTarget)
            error("Opcode " ~ opCode.name ~ " expects a target register", opCodeTok.location);

        if (target !is null && !opCode.hasTarget)
            error("Opcode " ~ opCode.name ~ " does not expect a target register", target.location);

        RegisterReferenceNode source1;
        RegisterReferenceNode source2;

        auto reg1 = peek();

        if (reg1.type == TokenType.identifier)
        {
            if (opCode.registers == 0)
                error("Opcode " ~ opCode.name ~ " takes no source registers", reg1.location);

            source1 = parseRegisterReference();

            auto reg2 = peek();

            if (reg2.type == TokenType.comma)
            {
                if (opCode.registers != 2)
                    error("Opcode " ~ opCode.name ~ " does not take two source registers", reg2.location);

                next();
                source2 = parseRegisterReference();
            }
        }

        InstructionOperandNode operand;

        auto operandType = opCode.operandType;

        if (operandType != OperandType.none)
        {
            consume("(");

            // If we're parsing a byte array or register selector, bring the
            // opening parenthesis back in.
            if (operandType == OperandType.bytes || operandType == OperandType.selector)
                _stream.movePrevious();

            operand = parseInstructionOperand(operandType);

            if (operandType != OperandType.bytes && operandType != OperandType.selector)
                consume(")");
        }

        consume(";");

        return new InstructionNode(opCodeTok.location, opCode, target, source1, source2, operand);
    }

    private InstructionOperandNode parseInstructionOperand(OperandType operandType)
    out (result)
    {
        assert(result);
    }
    body
    {
        InstructionOperand operand;
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
            case OperandType.bytes:
                auto literal = parseByteArrayLiteral();
                operand = literal;
                location = literal.location;
                break;
            case OperandType.label:
                auto block = parseBasicBlockReference();
                operand = block;
                location = block.location;
                break;
            case OperandType.type:
                auto type = parseTypeSpecification();
                operand = type;
                location = type.location;
                break;
            case OperandType.structure:
                auto type = parseStructureTypeReference();
                operand = type;
                location = type.location;
                break;
            case OperandType.field:
                auto field = parseFieldReference();
                operand = field;
                location = field.location;
                break;
            case OperandType.function_:
                auto method = parseFunctionReference();
                operand = method;
                location = method.location;
                break;
            case OperandType.signature:
                auto sig = parseFunctionPointerTypeReference();
                operand = sig;
                location = sig.location;
                break;
            case OperandType.selector:
                auto selector = parseRegisterSelector();
                operand = selector;
                location = selector.location;
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

                if (peek().type == TokenType.closeParen)
                    errorGot("register reference", peek.location, peek.value);
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
        auto name = parseSimpleName();

        return new BasicBlockReferenceNode(name.location, name);
    }

    private ByteArrayLiteralNode parseByteArrayLiteral()
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
            values.add(parseLiteralValue!ubyte());

            if (peek().type != TokenType.closeParen)
            {
                consume(",");

                if (peek().type == TokenType.closeParen)
                    errorGot("literal value", peek.location, peek.value);
            }
        }

        next();

        return new ByteArrayLiteralNode(open.location, values);
    }
}
