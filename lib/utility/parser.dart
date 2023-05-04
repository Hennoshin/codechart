import 'dart:convert';

import "data_classes.dart";

Token? opLookahead(List<Token> tokens, [bool fromLeft = false]) {
  int subCount = 0;
  String br1 = fromLeft ? bracketOpen : bracketClose;
  String br2 = fromLeft ? bracketClose : bracketOpen;
  String bra1 = fromLeft ? arrayBracketOpen : arrayBracketClose;
  String bra2 = fromLeft ? arrayBracketClose : arrayBracketOpen;

  for (Token token in fromLeft ? tokens : tokens.reversed) {
    if (subCount < 0) {
      return null;
    }

    if (token.val == br1 || token.val == bra1) {
      subCount += 1;
      continue;
    }
    if (token.val == br2 || token.val == bra2) {
      subCount -= 1;
      continue;
    }

    if (subCount == 0 && token.type == TokenType.operator) {
      return token;
    }
  }

  return null;
}



class Parser {
  static Map<int, List<String>> opPrecedenceGroup = {
    1: ["*", "/", "%"],
    2: ["+", "-"],
    3: ["<", "<=", ">", ">="],
    4: ["==", "!="],
    5: ["&"],
    6: ["^"],
    7: ["|"],
    8: ["&&"],
    9: ["||"],
  };

  static List<String> unaryOperator = [
    "+n",
    "-n",
    "!n",
    "~n"
  ];

  // Split the token list, ignore checking if token is inside bracket
  static List<Token> splitToken(List<String> targetVal, List<Token> src, [bool fromLeft = false]) {
    List<Token> res = List.empty(growable: true);
    int subCount = 0;
    String br1 = fromLeft ? bracketOpen : bracketClose;
    String br2 = fromLeft ? bracketClose : bracketOpen;
    String bra1 = fromLeft ? arrayBracketOpen : arrayBracketClose;
    String bra2 = fromLeft ? arrayBracketClose : arrayBracketOpen;

    Token token = fromLeft ? src.first : src.last;
    while (src.isNotEmpty && (!targetVal.any((target) => target == token.val) || subCount != 0)) {
      if (token.val == br1 || token.val == bra1) {
        subCount += 1;
      }
      if (subCount > 0 && (token.val == br2 || token.val == bra2)) {
        subCount -= 1;
      }

      if (fromLeft) {
        res.add(src.removeAt(0));
      }
      else {
        res.insert(0, src.removeLast());
      }

      if (src.isEmpty) break;
      token = fromLeft ? src.first : src.last;
    }

    return res;
  }


  static ASTNode parseStart(List<Token> tokens) {
    ASTNode? node;
    ASTNode? child;
    if (tokens.first.type == TokenType.functionReturn) {
      Token token = eatByType(TokenType.functionReturn, tokens, true);
      node = ASTNode(ASTNodeType.operator, token.val, token.val.runtimeType);

      if (tokens.isEmpty) {
        return node;
      }
    }

    child = parseRightToLeftS(null, tokens, opPrecedenceGroup[9]!, [], 9);

    if (node != null) {
      node.children.add(child);
      return node;
    }

    return child;
  }

  // EXPRRXS
  static ASTNode parseRightToLeftS(ASTNode? parent, List<Token> tokens, List<String> allowedOpList, List<String> lowerOp, int level) {
    ASTNode current = ASTNode.empty();

    ASTNode rightNode;
    Token? lookahead = opLookahead(tokens);
    if (lookahead != null && !allowedOpList.any((op) => lookahead.val == op)) {
      rightNode = parseRightToLeftS(current, tokens, opPrecedenceGroup[level - 1]!, lowerOp + allowedOpList, level - 1);
    }
    else {
      rightNode = parseSubRightToLeft(current, tokens);
    }

    current.children.add(rightNode);
    ASTNode? leftNode = parseRightToLeft(current, tokens, allowedOpList, lowerOp, level);
    if (leftNode != null) {
      current.children.insert(0, leftNode);
    }
    else {
      current = current.children[0];
    }

    return current;
  }

  // EXPRRX
  static ASTNode? parseRightToLeft(ASTNode parent, List<Token> tokens, List<String> allowedOpList, List<String> lowerOp, int level) {
    if (tokens.isEmpty) {
      return null;
    }
    if (tokens.last.type != TokenType.operator) {
      throw Exception("Operator expected");
    }

    if (lowerOp.any((op) => tokens.last.val == op)) {
      return null;
    }

    ASTNode current = ASTNode.empty();

    Token t = eatByVal(tokens.last.val, tokens);
    parent.type = ASTNodeType.operator;
    parent.value = t.val;

    ASTNode rightNode;
    Token? lookahead = opLookahead(tokens);
    if (lookahead != null && !(lowerOp + allowedOpList).any((op) => lookahead.val == op)) {
      rightNode = parseRightToLeftS(current, tokens, opPrecedenceGroup[level - 1]!, lowerOp + allowedOpList, level - 1);
    }
    else {
      rightNode = parseSubRightToLeft(current, tokens);
    }


    current.children.add(rightNode);
    ASTNode? leftNode = parseRightToLeft(current, tokens, allowedOpList, lowerOp, level);
    if (leftNode != null) {
      current.children.insert(0, leftNode);
    }
    else {
      current = current.children[0];
    }

    return current;
  }

  // EXPRT
  static ASTNode parseSubRightToLeft(ASTNode parent, List<Token> tokens) {
    Token lastToken = tokens.last;
    if (lastToken.type == TokenType.operator && lastToken.val != bracketClose && lastToken.val != arrayBracketClose) {
      throw Exception("Unexpected operator 1");
    }

    ASTNode newNode;
    if (lastToken.val == bracketClose || lastToken.val == arrayBracketClose) {
      lastToken = eatByVal(lastToken.val, tokens);
      List<Token> subTokens = splitToken([bracketOpen, arrayBracketOpen], tokens);
      if (lastToken.type == TokenType.functionCall) {
        newNode = ASTNode(ASTNodeType.operator, "fcall", String);
        parseFuncCall(newNode, subTokens);

        eatByVal(bracketOpen, tokens);
        lastToken = eatByType(TokenType.identifier, tokens);
        ASTNode child = ASTNode(ASTNodeType.identifier, lastToken.val, lastToken.val.runtimeType);
        newNode.children.insert(0, child);
      }
      else if (lastToken.val == arrayBracketClose) {
        newNode = ASTNode(ASTNodeType.operator, "arrayref", String);
        ASTNode child = parseRightToLeftS(null, subTokens, opPrecedenceGroup[9]!, List.empty(growable: true), 9);

        newNode.children.insert(0, child);
        eatByVal(arrayBracketOpen, tokens);

        lastToken = eatByType(TokenType.identifier, tokens);
        child = ASTNode(ASTNodeType.identifier, lastToken.val, lastToken.val.runtimeType);
        newNode.children.insert(0, child);
      }
      else {
        newNode = parseRightToLeftS(parent, subTokens, opPrecedenceGroup[9]!, List.empty(growable: true), 9);
        eatByVal(bracketOpen, tokens);
      }
    }

    else {
      lastToken = eatByType(tokens.last.type, tokens);
      if (lastToken.type == TokenType.identifier) {
        newNode = ASTNode(ASTNodeType.identifier, lastToken.val, lastToken.val.runtimeType);
      }
      else {
        Object converted = convertLiteralToken(lastToken);
        newNode = ASTNode(ASTNodeType.literal, converted, converted.runtimeType);
      }
    }

    while (tokens.isNotEmpty) {
      lastToken = tokens.last;
      if (lastToken.type != TokenType.unaryOperator) {
        break;
      }

      Token tmp = eatByType(TokenType.unaryOperator, tokens);
      ASTNode unaryNode = ASTNode(ASTNodeType.operator, tmp.val, tmp.val.runtimeType);
      unaryNode.children.add(newNode);
      newNode = unaryNode;
    }

    return newNode;

  }

  static void parseFuncCall(ASTNode node, List<Token> tokens) {
    bool firstLoop = true;
    while (tokens.isNotEmpty) {
      if (!firstLoop) {
        eatByVal(",", tokens);
      }
      List<Token> sub = splitToken([","], tokens);
      ASTNode child = parseRightToLeftS(null, sub, opPrecedenceGroup[9]!, List.empty(growable: true), 9);
      node.children.insert(0, child);
      firstLoop = false;
    }
  }

  static Token eatByVal(String target, List<Token> tokens, [bool fromLeft = false]) {
    Token source = fromLeft ? tokens.first : tokens.last;
    if (target == source.val) {
      return fromLeft ? tokens.removeAt(0) : tokens.removeLast();
    }

    throw Exception("Unexpected token 2");
  }
  static Token eatByType(TokenType target, List<Token> tokens, [bool fromLeft = false]) {
    Token source = fromLeft ? tokens.first : tokens.last;
    if (target == source.type) {
      return fromLeft ? tokens.removeAt(0) : tokens.removeLast();
    }

    throw Exception("Unexpected token 3");
  }
  static Object convertLiteralToken(Token token) {
    switch (token.type) {
      case TokenType.floatLiteral:
        return double.parse(token.val);
        
      case TokenType.numberLiteral:
        return int.parse(token.val);
        
      case TokenType.boolean:
        if (token.val == "true") return true;
        return false;

      case TokenType.stringLiteral:
        return jsonDecode(token.val);

      default:
        throw Exception("Unexpected Token Type");
    }
  }
}