import "data_classes.dart";

class Lexer {
  static bool isCharOperatorSymbol(String ch) {
    return  ch == bracketOpen ||
        ch == bracketClose ||
        ch == arrayBracketOpen ||
        ch == arrayBracketClose ||
        ch == operatorAddition ||
        ch == operatorSubtraction ||
        ch == operatorUnaryBitwiseNot ||
        ch == operatorMultiplication ||
        ch == operatorDivision ||
        ch == operatorModulo ||
        ch == operatorBitwiseXor ||
        ch == operatorAssignment ||
        ch == operatorBitwiseAnd ||
        ch == operatorBitwiseOr ||
        ch == operatorUnaryLogicalNot ||
        ch == operatorLessThan ||
        ch == operatorMoreThan ||
        ch == operatorComma;
  }

  static int isSequenceOperator(String str, String lookahead) {
    if (str == bracketOpen ||
        str == bracketClose ||
        str == arrayBracketOpen ||
        str == arrayBracketClose ||
        str == operatorAddition ||
        str == operatorSubtraction ||
        str == operatorUnaryBitwiseNot ||
        str == operatorDivision ||
        str == operatorModulo ||
        str == operatorBitwiseXor ||
        str == operatorComma ||
        // str == "**" ||
        str == operatorMultiplication ||
        str == operatorLessThanOrEqual ||
        str == operatorMoreThanOrEqual ||
        str == operatorEqual ||
        str == operatorNotEqual ||
        str == operatorLogicalAnd ||
        str == operatorLogicalOr ||
        // (str == "*" && lookahead != '*') ||
        ((str == operatorUnaryLogicalNot || str == operatorLessThan || str == operatorMoreThan) && lookahead != '=') ||
        (str == operatorBitwiseAnd && lookahead != '&') ||
        (str == operatorBitwiseOr && lookahead != '|')) {

      return 2;
    }

    if (// str == "*" ||
        str == "=" ||
        str == "!" ||
        str == "<" ||
        str == ">" ||
        str == "&" ||
        str == "|") {

      return 1;
    }

    return 0;
  }

  static bool isSequenceBoolean(String str, String lookahead) {
    if ((str == "true" || str == "false") && (!RegExp(r'[A-Za-z0-9]').hasMatch(lookahead) || lookahead == '_')) {
      return true;
    }

    return false;
  }

  static int isNextSequenceIdentifier(String lookahead) {
    if (RegExp(r'[A-Za-z0-9_]').hasMatch(lookahead)) {
      return 1;
    }

    return 0;
  }
  static int isNextSequenceNumber(String lookahead, {bool hasDecimal = false}) {
    if (lookahead == '.' && !hasDecimal) {
      return 2;
    }
    if (RegExp(r'[0-9]').hasMatch(lookahead)) {
      return 1;
    }

    return 0;
  }

  // TODO: Make sure to lex escape characters in string literals
  static List<Token> lex(String expr) {
    List<Token> list = List.empty(growable: true);
    int lookaheadIndex = 0;
    String lookahead = '';
    String curString = "";
    List<Token> openedBrackets = List.empty(growable: true);

    bool isString = false;
    bool isOp = false;
    bool isNumber = false;
    bool hasDecimal = false;
    bool isCharSequence = false;

    for (String c in expr.split('')) {
      curString += c;
      lookaheadIndex += 1;
      lookahead = lookaheadIndex < expr.length ? expr[lookaheadIndex] : "";

      if (c == '"' && isString) {
        list.add(Token(TokenType.stringLiteral, curString));
        curString = "";
        isString = false;
        continue;
      }
      if (c == '"') {
        isString = true;
      }
      if (isString) {
        continue;
      }


      if (curString.length == 1) {
        if (c == ' ') {
          curString = "";
          continue;
        }

        if (Lexer.isCharOperatorSymbol(c)) {
          isOp = true;
        }
        else if (RegExp(r'[0-9]').hasMatch(c)) {
          isNumber = true;
        }
        else if (RegExp(r'[a-zA-Z0-9_]').hasMatch(c)) {
          isCharSequence = true;
        }
      }

      if (isOp && Lexer.isSequenceOperator(curString, lookahead) == 2) {
        if (curString == "!" || curString == "~") {
          list.add(Token(TokenType.unaryOperator, "${curString}n"));
        }
        else if ((curString == "+" || curString == "-") && (list.isEmpty || list.last.type == TokenType.operator || list.last.type == TokenType.unaryOperator)) {
          list.add(Token(TokenType.unaryOperator, "${curString}n"));
        }
        else if ((list.isNotEmpty && list.last.type == TokenType.identifier && curString == "(") ||
            (curString == ")" && openedBrackets.last.type == TokenType.functionCall)) {
          list.add(Token(TokenType.functionCall, curString));
        }
        else {
          list.add(Token(TokenType.operator, curString));
        }
        curString = "";
        isOp = false;

        if (list.last.val == bracketOpen || list.last.val == arrayBracketOpen) {
          openedBrackets.add(list.last);
        }
        if (list.last.val == bracketClose || list.last.val == arrayBracketClose) {
          Token t = openedBrackets.removeLast();
          if (list.last.val == bracketClose && t.val != bracketOpen || list.last.val == arrayBracketClose && t.val != arrayBracketOpen) {
            throw Exception("Mismatch closing bracket");
          }
        }
      }
      if (isNumber) {
        int res = Lexer.isNextSequenceNumber(lookahead, hasDecimal : hasDecimal);
        switch (res) {
          case 2:
            hasDecimal = true;
            break;

          case 0:
            TokenType t = int.tryParse(curString) == null ? TokenType.floatLiteral : TokenType.numberLiteral;
            list.add(Token(t, curString));
            curString = "";
            isNumber = false;
            hasDecimal = false;
            break;
        }
      }
      if (isCharSequence && Lexer.isSequenceBoolean(curString, lookahead)) {
        list.add(Token(TokenType.boolean, curString));
        curString = "";
        isCharSequence = false;
      }
      if (isCharSequence && Lexer.isNextSequenceIdentifier(lookahead) == 0) {
        if (curString == "return") {
          list.add(Token(TokenType.functionReturn, curString));
        }
        else {
          list.add(Token(TokenType.identifier, curString));
        }
        curString = "";
        isCharSequence = false;
      }
    }
    return list;
  }
}