const arrayBracketOpen = "[";
const arrayBracketClose = "]";
const bracketOpen = "(";
const bracketClose = ")";
const functionCallBracketOpen = bracketOpen;
const functionCallBracketClose = bracketClose;
const operatorUnaryPlus = "+";
const operatorUnaryMinus = "-";
const operatorUnaryLogicalNot = "!";
const operatorUnaryBitwiseNot = "~";
const operatorAddition = operatorUnaryPlus;
const operatorSubtraction = operatorUnaryMinus;
const operatorMultiplication = "*";
const operatorDivision = "/";
const operatorModulo = "%";
const operatorLessThan = "<";
const operatorLessThanOrEqual = "<=";
const operatorMoreThan = ">";
const operatorMoreThanOrEqual = ">=";
const operatorEqual = "==";
const operatorNotEqual = "!=";
const operatorBitwiseAnd = "&";
const operatorBitwiseXor = "^";
const operatorBitwiseOr = "|";
const operatorLogicalAnd = "&&";
const operatorLogicalOr = "||";
const operatorAssignment = "=";
const operatorComma = ",";

const returnStatement = "return";

enum TokenType {
  floatLiteral,
  numberLiteral,
  stringLiteral,
  boolean,
  identifier,
  operator,
  unaryOperator,
  functionCall,
  functionReturn
}

enum ASTNodeType {
  operator,
  literal,
  identifier
}

class Token {
  String val;
  TokenType type;
  Token(this.type, this.val);
}

// TODO: [valueType] is redundant, consider removing
class ASTNode {
  late ASTNodeType type;
  late Object value;
  late Type valueType;

  List<ASTNode> children = [];

  ASTNode(this.type, this.value, this.valueType);
  ASTNode.empty();
}