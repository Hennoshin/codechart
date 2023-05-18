import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/models/function_flowchart.dart';
import 'package:code_chart/utility/data_classes.dart';
import 'package:code_chart/utility/lexer.dart';
import 'package:code_chart/utility/parser.dart';

import '../models/base_element.dart';
import "memory.dart";

class _StackAST {
  List<ASTNode> ast = [];
  int offset = 0;         // Represents current pointer from the end of list

  ASTNode pop() {
    offset -= 1;
    return ast.last;
  }

  ASTNode removeFromCurrentPosition([int? addOffset]) {
    ASTNode node = ast.removeAt(currentPointer + (addOffset ?? 0));
    offset -= 1;
    return node;
  }

  int get lastIndex => ast.length - 1;
  int get currentPointer => lastIndex - offset;
}

class ExecutionEnvironment {
  List<Memory> memoryStack;
  Map<String, FunctionFlowchart> functionTable;
  BaseElement currentElement;
  List<_StackAST> _currentAST = [];

  ExecutionEnvironment(this.currentElement, this.functionTable) : memoryStack = [Memory("Main")];

  void createNewMemoryStack(String name) {
    memoryStack.add(Memory(name));
  }

  void destroyTopMemoryStack() {
    memoryStack.removeLast();
  }

  void saveExecutionState(int astStackIndex) {
    topStack.hiddenVariables["lastAST"] = _currentAST;
    topStack.hiddenVariables["lastASTIndex"] = astStackIndex;
    topStack.hiddenVariables["lastElement"] = currentElement;
  }

  int loadExecutionState() {
    _currentAST = topStack.hiddenVariables["lastAST"]!;
    currentElement = topStack.hiddenVariables["lastElement"]!;

    return topStack.hiddenVariables["lastASTIndex"]!;
  }

  void runElement() {
    List<ASTNode> exprResults = [];
    for (String? expr in currentElement.expr) {
      ASTNode ast = Parser.parseRightToLeftS(null, Lexer.lex(expr!), Parser.opPrecedenceGroup[9]!, [], 9);
      exprResults.add(interpretAST(ast));
    }
    currentElement = currentElement.evaluate(topStack, exprResults);
  }

  bool stepRunElement() {
    if (_currentAST.isEmpty) {
      for (String? expr in currentElement.expr) {
        ASTNode ast = Parser.parseStart(Lexer.lex(expr!));
        _StackAST sast = _StackAST();
        sast.ast = convertASTToStack(ast);
        _currentAST.add(sast);
      }
    }

    currentElement = interpretCurrentASTStack();

    return memoryStack.isNotEmpty;
  }

  List<ASTNode> convertASTToStack(ASTNode ast) {
    List<ASTNode> stack = [];

    stack.add(ast);
    for (ASTNode children in ast.children.reversed) {
      stack += convertASTToStack(children);
    }

    return stack;
  }

  /*
   * Interpret the current element ASTs
   * Expected to consume the current ASTs stack
   */
  BaseElement interpretCurrentASTStack() {
    for (_StackAST ast in _currentAST) {
      while (ast.ast.isNotEmpty && ast.currentPointer >= 0) {
        ASTNode node = ast.ast[ast.currentPointer];

        if (node.type == ASTNodeType.literal) {
          ast.offset += 1;
        }
        
        if (node.type == ASTNodeType.identifier && node.value is String) {
          Object? programObject = topStack.containsVariable(node.value as String) ? topStack.getData(node.value as String) : functionTable[node.value];
          if (programObject == null) {
            throw Exception("Unknown variable. The identifier is neither a variable nor a function, ${currentElement.expr}");
          }

          ast.ast[ast.currentPointer] = ASTNode(ASTNodeType.identifier, programObject, programObject.runtimeType);
          ast.offset += 1;
        }
        
        if (node.type == ASTNodeType.operator) {
          switch (node.value) {
            case "fcall":
              int addOffset = ast.ast.indexWhere((element) => element.value is FunctionFlowchart, ast.currentPointer) - ast.currentPointer;
              FunctionFlowchart func = ast.removeFromCurrentPosition(addOffset).value as FunctionFlowchart;
              addOffset -= 1;

              if (func.argList.length != addOffset) {
                throw Exception("Invalid function call to ${func.name}, expected ${func.argList.length} arguments, $addOffset given");
              }
              Memory currentMemory = topStack;
              createNewMemoryStack(func.name);

              for (var farg in func.argList) {
                ASTNode args = ast.removeFromCurrentPosition(addOffset);
                ASTNode exposed = convertIdentifierToLiteral(args);
                if (exposed.value.runtimeType != dataTypeMap[farg.type]!) {
                  throw Exception("erro");
                }

                if (farg.type == DataType.integer) {
                  topStack.addNewVariables<int>(farg.name);
                }
                if (farg.type == DataType.real) {
                  topStack.addNewVariables<double>(farg.name);
                }
                if (farg.type == DataType.boolean) {
                  topStack.addNewVariables<bool>(farg.name);
                }
                if (farg.type == DataType.string) {
                  topStack.addNewVariables<String>(farg.name);
                }
                var wrapper = topStack.getData(farg.name);
                topStack.assignVariable(wrapper, args.value);

                addOffset -= 1;
              }

              int temp = _currentAST.indexOf(ast);
              currentMemory.hiddenVariables["lastASTIndex"] = temp;
              currentMemory.hiddenVariables["lastAST"] = _currentAST;
              currentMemory.hiddenVariables["lastElement"] = currentElement;
              _currentAST = [];

              return func.startElement;

            case "return":
              _functionReturn(ast);

              return currentElement;

            case "+":
              ASTNode result = _binaryOperator(ast, addOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            case "-":
              ASTNode result = _binaryOperator(ast, minusOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            case "*":
              ASTNode result = _binaryOperator(ast, multiplicationOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            case "/":
              ASTNode result = _binaryOperator(ast, divisionOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            case "%":
              ASTNode result = _binaryOperator(ast, moduloOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            case ">=":
              ASTNode result = _binaryOperator(ast, moreThanOrEqualOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            default:
              throw Exception("Unknown Operator");
          }
        }
      }
    }
    
    List<ASTNode> results = _currentAST.map((e) => e.ast.single).toList();
    var element = currentElement.evaluate(topStack, results);
    _currentAST = [];
    return element;
  }


  ASTNode interpretAST(ASTNode ast) {
    List<ASTNode> results = [];
    for (ASTNode children in ast.children) {
      results.add(interpretAST(children));
    }

    if (ast.type == ASTNodeType.literal) {
      return ast;
    }

    if (ast.type == ASTNodeType.identifier && ast.value.runtimeType == String) {

      Object? programObject = topStack.containsVariable(ast.value as String) ? topStack.getData(ast.value as String) : functionTable[ast.value];
      if (programObject == null) {
        throw Exception("Unknown variable. The identifier is neither a variable nor a function");
      }
      return ASTNode(ASTNodeType.identifier, programObject, programObject.runtimeType);
    }

    if (ast.type == ASTNodeType.operator) {
      ASTNode leftNode;
      ASTNode rightNode;
      switch (ast.value) {
        case "fcall":
          leftNode = results.first;
          if (leftNode is! FunctionFlowchart) {
            throw Exception("Function identifier expected");
          }

          break;

        case "+":
          leftNode = convertIdentifierToLiteral(results.first);
          rightNode = convertIdentifierToLiteral(results.last);
          return addOperator(leftNode, rightNode);

        case "-":
          leftNode = convertIdentifierToLiteral(results.first);
          rightNode = convertIdentifierToLiteral(results.last);
          return minusOperator(leftNode, rightNode);

        case "*":
          leftNode = convertIdentifierToLiteral(results.first);
          rightNode = convertIdentifierToLiteral(results.last);
          return multiplicationOperator(leftNode, rightNode);

        case "/":
          leftNode = convertIdentifierToLiteral(results.first);
          rightNode = convertIdentifierToLiteral(results.last);
          return divisionOperator(leftNode, rightNode);

        case "%":
          leftNode = convertIdentifierToLiteral(results.first);
          rightNode = convertIdentifierToLiteral(results.last);
          return moduloOperator(leftNode, rightNode);

        case ">=":
          leftNode = convertIdentifierToLiteral(results.first);
          rightNode = convertIdentifierToLiteral(results.last);
          return moreThanOrEqualOperator(leftNode, rightNode);

        default:
          throw Exception("Unknown Operator");
      }
    }

    throw Exception("Unknown error, this should not happen");
  }


  ASTNode convertIdentifierToLiteral(ASTNode operand) {
    if (operand.type == ASTNodeType.literal) {
      return operand;
    }

    var val = operand.value;
    Wrapper op;
    if (val is Wrapper) {
      op = val;
    }
    else {
      throw Exception("Unexpected identifier. The identifier is not referring to a variable");
    }

    return ASTNode(ASTNodeType.literal, op.value!, op.runtimeType);
  }

  void _functionReturn(_StackAST ast) {
    ASTNode? returnVal;
    if (ast.offset != 0) {
      returnVal = convertIdentifierToLiteral(ast.removeFromCurrentPosition(1));
    }

    destroyTopMemoryStack();
    if (memoryStack.isEmpty){
      return;
    }

    int index = loadExecutionState();
    var stack = _currentAST[index];
    stack.ast[stack.currentPointer] = returnVal ?? ASTNode.empty();
  }

  /*
   * Binary operator function
   * Consumes the operands from the AST Stack
   */
  ASTNode _binaryOperator(_StackAST ast, Function opFunc) {
    ASTNode rightNode = ast.removeFromCurrentPosition(1);
    ASTNode leftNode = ast.removeFromCurrentPosition(1);

    leftNode = convertIdentifierToLiteral(leftNode);
    rightNode = convertIdentifierToLiteral(rightNode);
    ASTNode result = opFunc(leftNode, rightNode);

    return result;
  }

  ASTNode addOperator(ASTNode leftOp, ASTNode rightOp) {
    Object result;
    if (leftOp.valueType == String && rightOp.valueType == String) {
      result = (leftOp.value as String) + (rightOp.value as String);
    }
    else if (leftOp.value is num && rightOp.value is num) {
      result = (leftOp.value as num) + (rightOp.value as num);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode minusOperator(ASTNode leftOp, ASTNode rightOp) {
    Object result;
    if (leftOp.value is num && rightOp.value is num) {
      result = (leftOp.value as num) - (rightOp.value as num);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode divisionOperator(ASTNode leftOp, ASTNode rightOp) {
    Object result;
    if (leftOp.value is int && rightOp.value is int) {
      result = (leftOp.value as int) ~/ (rightOp.value as int);
    }
    else if (leftOp.value is num && rightOp.value is num) {
      result = (leftOp.value as num) / (rightOp.value as num);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode multiplicationOperator(ASTNode leftOp, ASTNode rightOp) {
    Object result;
    if (leftOp.value is num && rightOp.value is num) {
      result = (leftOp.value as num) * (rightOp.value as num);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode moduloOperator(ASTNode leftOp, ASTNode rightOp) {
    Object result;
    if (leftOp.value is num && rightOp.value is num) {
      result = (leftOp.value as num) % (rightOp.value as num);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode unaryMinusOperator(ASTNode leftOp) {
    Object result;
    if (leftOp.value is num) {
      result = -(leftOp.value as num);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode unaryPlusOperator(ASTNode leftOp) {
    Object result;
    if (leftOp.value is num) {
      result = (leftOp.value as num);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode bitwiseNotOperator(ASTNode leftOp) {
    Object result;
    if (leftOp.value is int) {
      result = ~(leftOp.value as int);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode booleanNotOperator(ASTNode leftOp) {
    Object result;
    if (leftOp.value is bool) {
      result = !(leftOp.value as bool);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode lessThanOperator(ASTNode leftOp, ASTNode rightOp) {
    Object result;
    if (leftOp.value is num && rightOp.value is num) {
      result = (leftOp.value as num) < (rightOp.value as num);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode lessThanOrEqualOperator(ASTNode leftOp, ASTNode rightOp) {
    Object result;
    if (leftOp.value is num && rightOp.value is num) {
      result = (leftOp.value as num) <= (rightOp.value as num);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode moreThanOperator(ASTNode leftOp, ASTNode rightOp) {
    Object result;
    if (leftOp.value is num && rightOp.value is num) {
      result = (leftOp.value as num) > (rightOp.value as num);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode moreThanOrEqualOperator(ASTNode leftOp, ASTNode rightOp) {
    Object result;
    if (leftOp.value is num && rightOp.value is num) {
      result = (leftOp.value as num) >= (rightOp.value as num);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode equalOperator(ASTNode leftOp, ASTNode rightOp) {
    Object result;
    if (leftOp.value.runtimeType == rightOp.value.runtimeType || (leftOp.value is num && rightOp.value is num)) {
      result = leftOp.value == rightOp.value;
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode notEqualOperator(ASTNode leftOp, ASTNode rightOp) {
    Object result;
    if (leftOp.value.runtimeType == rightOp.value.runtimeType || (leftOp.value is num && rightOp.value is num)) {
      result = leftOp.value != rightOp.value;
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode bitwiseAndOperator(ASTNode leftOp, ASTNode rightOp) {
    Object result;
    if (leftOp.value is int && rightOp.value is int) {
      result = (leftOp.value as int) & (rightOp.value as int);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode bitwiseXorOperator(ASTNode leftOp, ASTNode rightOp) {
    Object result;
    if (leftOp.value is int && rightOp.value is int) {
      result = (leftOp.value as int) ^ (rightOp.value as int);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode bitwiseOrOperator(ASTNode leftOp, ASTNode rightOp) {
    Object result;
    if (leftOp.value is int && rightOp.value is int) {
      result = (leftOp.value as int) | (rightOp.value as int);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode logicalAndOperator(ASTNode leftOp, ASTNode rightOp) {
    Object result;
    if (leftOp.value is bool && rightOp.value is bool) {
      result = (leftOp.value as bool) && (rightOp.value as bool);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  ASTNode logicalOrOperator(ASTNode leftOp, ASTNode rightOp) {
    Object result;
    if (leftOp.value is bool && rightOp.value is bool) {
      result = (leftOp.value as bool) || (rightOp.value as bool);
    }
    else {
      throw Exception("Unexpected operands type.");
    }

    return ASTNode(ASTNodeType.literal, result, result.runtimeType);
  }

  /*
  ASTNode addOperator(ASTNode leftOp, ASTNode rightOp) {
    if (leftOp.valueType == TokenType.identifier) {
      leftOp = varToNodeValue(leftOp, topStack);
    }

    if (rightOp.valueType == TokenType.identifier) {
      rightOp = varToNodeValue(rightOp, topStack);
    }

    if (leftOp.valueType == TokenType.numberLiteral) {
      if (rightOp.valueType == TokenType.numberLiteral) {
        String value = (int.parse(leftOp.value) + int.parse(rightOp.value)).toString();
        return ASTNode(ASTNodeType.variable, value, TokenType.numberLiteral);
      }

      if (rightOp.valueType == TokenType.floatLiteral) {
        String value = (double.parse(leftOp.value) + double.parse(rightOp.value)).toString();
        return ASTNode(ASTNodeType.variable, value, TokenType.floatLiteral);
      }
    }

    if (leftOp.valueType == TokenType.floatLiteral && (rightOp.valueType == TokenType.floatLiteral || rightOp.valueType == TokenType.numberLiteral)) {
      String value = (double.parse(leftOp.value) + double.parse(rightOp.value)).toString();
      return ASTNode(ASTNodeType.variable, value, TokenType.floatLiteral);
    }

    if (leftOp.valueType == TokenType.stringLiteral && rightOp.valueType == TokenType.stringLiteral) {
      String value = (leftOp.value.substring(0, leftOp.value.length - 1) + rightOp.value.substring(1));
      return ASTNode(ASTNodeType.variable, value, TokenType.stringLiteral);
    }

    throw Exception("Unexpected operands type. Expected value is STRING + STRING or NUMBER + NUMBER");
  }

  ASTNode minusOperator(ASTNode leftOp, ASTNode rightOp) {
    if (leftOp.valueType == TokenType.identifier) {
      leftOp = varToNodeValue(leftOp, topStack);
    }

    if (rightOp.valueType == TokenType.identifier) {
      rightOp = varToNodeValue(rightOp, topStack);
    }

    if (leftOp.valueType == TokenType.numberLiteral) {
      if (rightOp.valueType == TokenType.numberLiteral) {
        String value = (int.parse(leftOp.value) - int.parse(rightOp.value)).toString();
        return ASTNode(ASTNodeType.variable, value, TokenType.numberLiteral);
      }

      if (rightOp.valueType == TokenType.floatLiteral) {
        String value = (double.parse(leftOp.value) - double.parse(rightOp.value)).toString();
        return ASTNode(ASTNodeType.variable, value, TokenType.floatLiteral);
      }
    }

    if (leftOp.valueType == TokenType.floatLiteral && (rightOp.valueType == TokenType.floatLiteral || rightOp.valueType == TokenType.numberLiteral)) {
      String value = (double.parse(leftOp.value) - double.parse(rightOp.value)).toString();
      return ASTNode(ASTNodeType.variable, value, TokenType.floatLiteral);
    }

    throw Exception("Unexpected operands type. Expected value is NUMBER - NUMBER");
  }

  ASTNode multiplicationOperator(ASTNode leftOp, ASTNode rightOp) {
    if (leftOp.valueType == TokenType.identifier) {
      leftOp = varToNodeValue(leftOp, topStack);
    }

    if (rightOp.valueType == TokenType.identifier) {
      rightOp = varToNodeValue(rightOp, topStack);
    }

    if (leftOp.valueType == TokenType.numberLiteral) {
      if (rightOp.valueType == TokenType.numberLiteral) {
        String value = (int.parse(leftOp.value) * int.parse(rightOp.value)).toString();
        return ASTNode(ASTNodeType.variable, value, TokenType.numberLiteral);
      }

      if (rightOp.valueType == TokenType.floatLiteral) {
        String value = (double.parse(leftOp.value) * double.parse(rightOp.value)).toString();
        return ASTNode(ASTNodeType.variable, value, TokenType.floatLiteral);
      }
    }

    if (leftOp.valueType == TokenType.floatLiteral && (rightOp.valueType == TokenType.floatLiteral || rightOp.valueType == TokenType.numberLiteral)) {
      String value = (double.parse(leftOp.value) * double.parse(rightOp.value)).toString();
      return ASTNode(ASTNodeType.variable, value, TokenType.floatLiteral);
    }

    throw Exception("Unexpected operands type. Expected value is NUMBER * NUMBER");
  }

  ASTNode divisionOperator(ASTNode leftOp, ASTNode rightOp) {
    if (leftOp.valueType == TokenType.identifier) {
      leftOp = varToNodeValue(leftOp, topStack);
    }

    if (rightOp.valueType == TokenType.identifier) {
      rightOp = varToNodeValue(rightOp, topStack);
    }

    if (leftOp.valueType == TokenType.numberLiteral) {
      if (rightOp.valueType == TokenType.numberLiteral) {
        String value = (int.parse(leftOp.value) ~/ int.parse(rightOp.value)).toString();
        return ASTNode(ASTNodeType.variable, value, TokenType.numberLiteral);
      }

      if (rightOp.valueType == TokenType.floatLiteral) {
        String value = (double.parse(leftOp.value) / double.parse(rightOp.value)).toString();
        return ASTNode(ASTNodeType.variable, value, TokenType.floatLiteral);
      }
    }

    if (leftOp.valueType == TokenType.floatLiteral && (rightOp.valueType == TokenType.floatLiteral || rightOp.valueType == TokenType.numberLiteral)) {
      String value = (double.parse(leftOp.value) / double.parse(rightOp.value)).toString();
      return ASTNode(ASTNodeType.variable, value, TokenType.floatLiteral);
    }

    throw Exception("Unexpected operands type. Expected value is NUMBER / NUMBER");
  }


  ASTNode varToNodeValue(ASTNode operand, Memory memory) {
    if (operand.type != ASTNodeType.variable || operand.valueType != TokenType.identifier) throw Exception("Unexpected function call, unexpected node type");

    ImmediateData val = memory.getData(operand.value);
    if (val.value == null) {
      throw Exception("Variable ${operand.value} has not been initialized");
    }

    TokenType valType;
    if (val.type == DataType.string) {
      valType = TokenType.stringLiteral;
    } else if (val.type == DataType.float) {
      valType = TokenType.floatLiteral;
    } else if (val.type == DataType.integer) {
      valType = TokenType.numberLiteral;
    } else if (val.type == DataType.boolean) {
      valType = TokenType.boolean;
    } else {
      valType = TokenType.identifier;
    }

    return ASTNode(ASTNodeType.variable, val.value!, valType);
  }
   */


  Memory get topStack => memoryStack.last;


}