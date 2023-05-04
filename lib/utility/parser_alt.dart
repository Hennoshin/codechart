/*
import "data_classes.dart";

Token? opLookahead(List<Token> tokens, [bool fromLeft = false]) {
  int subCount = 0;
  String br1 = fromLeft ? "(" : ")";
  String br2 = fromLeft ? ")" : "(";

  for (Token token in fromLeft ? tokens : tokens.reversed) {
    if (subCount < 0) {
      return null;
    }

    if (token.val == br1) {
      subCount += 1;
      continue;
    }
    if (token.val == br2) {
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
    String br1 = fromLeft ? "(" : ")";
    String br2 = fromLeft ? ")" : "(";

    Token token = fromLeft ? src.first : src.last;
    while (src.isNotEmpty && (!targetVal.any((target) => target == token.val) || subCount != 0)) {
      if (token.val == br1) {
        subCount += 1;
      }
      if (subCount > 0 && token.val == br2) {
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


  // EXPRRXS
  static ASTNode parseRightToLeftS(ASTNode? parent, List<Token> tokens, List<String> allowedOpList, List<String> lowerOp, int level) {
    ASTNode current = ASTNode.empty();

    ASTNode rightNode;
    Token? lookahead = opLookahead(tokens);
    print("Lookahead: ${lookahead!.val}");
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
    print("Lookahead 2: ${lookahead?.val ?? "EMPTY"}");
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
    if (lastToken.type == TokenType.operator && lastToken.val != ")") {
      throw Exception("Unexpected operator 1");
    }

    ASTNode newNode;
    if (tokens.last.val == ")") {
      eatByVal(")", tokens);
      List<Token> subTokens = splitToken(["("], tokens);
      newNode = parseLeftToRightS(parent, subTokens, opPrecedenceGroup[10]!, List.empty(growable: true), 10);
      eatByVal("(", tokens);

    }
    else {
      lastToken = tokens.last;
      eatByType(tokens.last.type, tokens);
      newNode = ASTNode(ASTNodeType.variable, lastToken.val);
    }

    while (tokens.isNotEmpty) {
      lastToken = tokens.last;
      if (lastToken.type != TokenType.unaryOperator) {
        break;
      }

      Token tmp = eatByType(TokenType.unaryOperator, tokens);
      ASTNode unaryNode = ASTNode(ASTNodeType.operator, tmp.val);
      unaryNode.children.add(newNode);
      newNode = unaryNode;
    }

    return newNode;

  }


  // EXPRLXS
  static ASTNode parseLeftToRightS(ASTNode? parent, List<Token> tokens, List<String> allowedOpList, List<String> lowerOp, int level) {
    ASTNode current = ASTNode.empty();

    ASTNode leftNode;
    Token? lookahead = opLookahead(tokens, true);
    print(lookahead?.val ?? "EMPTY");
    if (lookahead != null && !allowedOpList.any((op) => lookahead.val == op)) {
      List<Token> newTokens = splitToken(allowedOpList, tokens, true);
      leftNode = parseRightToLeftS(current, newTokens, opPrecedenceGroup[level - 1]!, lowerOp + allowedOpList, level - 1);
    }
    else {
      leftNode = parseSubLeftToRight(current, tokens);
    }

    current.children.add(leftNode);
    ASTNode? rightNode = parseLeftToRight(current, tokens, allowedOpList, lowerOp, level);
    if (rightNode != null) {
      current.children.add(rightNode);
    }
    else {
      current = current.children[0];
    }

    return current;
  }

  // EXPRLX
  static ASTNode? parseLeftToRight(ASTNode parent, List<Token> tokens, List<String> allowedOpList, List<String> lowerOp, int level) {
    if (tokens.isEmpty) {
      return null;
    }
    if (tokens.first.type != TokenType.operator) {
      throw Exception("Operator expected");
    }

    if (lowerOp.any((op) => tokens.first.val == op)) {
      return null;
    }

    ASTNode current = ASTNode.empty();

    Token t = eatByVal(tokens.first.val, tokens, true);
    parent.type = ASTNodeType.operator;
    parent.value = t.val;

    ASTNode leftNode;
    Token? lookahead = opLookahead(tokens, true);
    print("Lookahead 2: ${lookahead?.val ?? "EMPTY"}");
    if (lookahead != null && !(lowerOp + allowedOpList).any((op) => lookahead.val == op)) {
      List<Token> newTokens = splitToken(allowedOpList, tokens, true);
      leftNode = parseRightToLeftS(current, newTokens, opPrecedenceGroup[level - 1]!, lowerOp + allowedOpList, level - 1);
    }
    else {
      leftNode = parseSubLeftToRight(current, tokens);
    }


    current.children.add(leftNode);
    ASTNode? rightNode = parseLeftToRight(current, tokens, allowedOpList, lowerOp, level);
    if (rightNode != null) {
      current.children.insert(0, rightNode);
    }
    else {
      current = current.children[0];
    }

    return current;
  }

  static ASTNode parseSubLeftToRight(ASTNode parent, List<Token> tokens) {
    Token lastToken = tokens.first;
    if (lastToken.type == TokenType.operator && lastToken.val != "(") {
      throw Exception("Unexpected operator 1");
    }

    ASTNode? node1;
    ASTNode? node2;
    while (tokens.isNotEmpty) {
      lastToken = tokens.first;
      if (lastToken.type != TokenType.unaryOperator) {
        break;
      }

      Token tmp = eatByType(TokenType.unaryOperator, tokens, true);
      node2 = ASTNode(ASTNodeType.operator, tmp.val);
      if (node1 != null) {
        node1.children.add(node2);
      }
      else {
        node1 = node2;
      }
    }

    ASTNode newNode = ASTNode.empty();
    if (tokens.first.val == "(") {
      eatByVal("(", tokens, true);
      List<Token> subTokens = splitToken([")"], tokens, true);
      print(tokens.first.val + "\n");
      newNode = parseLeftToRightS(parent, subTokens, opPrecedenceGroup[10]!, List.empty(growable: true), 10);
      eatByVal(")", tokens, true);
    }
    else {
      lastToken = tokens.first;
      eatByType(tokens.first.type, tokens, true);
      newNode = ASTNode(ASTNodeType.variable, lastToken.val);
    }

    if (node2 != null) {
      node2.children.add(newNode);
    }

    return node1 ?? newNode;

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
}

 */