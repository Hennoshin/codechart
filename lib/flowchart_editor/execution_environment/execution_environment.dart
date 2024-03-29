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

// TODO: Separate the binary operators into another class
class ExecutionEnvironment {
  final List<Memory> memoryStack;
  final Map<String, FunctionFlowchart> functionTable;
  BaseElement currentElement;
  List<_StackAST> _currentAST = [];

  late Map<String, Function> _predefinedFunctions;

  bool _expectingInput = false;
  Wrapper? _inputVariable;
  final List<String> _consoleBuffer = [];

  ExecutionEnvironment(this.currentElement, this.functionTable) : memoryStack = [Memory("Main")] {
    _predefinedFunctions = {
      "output": consoleOutput,
      "input": inputConsole,
    };
  }

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

  bool stepRunElement() {
    if (_expectingInput) {
      return memoryStack.isNotEmpty;
    }

    if (_currentAST.isEmpty) {
      for (String? expr in currentElement.exprList) {
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

  // TODO: Add all operators
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
          Object? programObject = _predefinedFunctions[node.value];
          programObject ??= topStack.containsVariable(node.value as String) ? topStack.getData(node.value as String) : functionTable[node.value];
          if (programObject == null) {
            throw Exception("Unknown variable. The identifier is neither a variable nor a function, ${node.value}");
          }

          ast.ast[ast.currentPointer] = ASTNode(ASTNodeType.identifier, programObject, programObject.runtimeType);
          ast.offset += 1;
        }
        
        if (node.type == ASTNodeType.operator) {
          switch (node.value) {
            case "fcall":
              int addOffset = ast.ast.indexWhere((element) => (element.value is FunctionFlowchart) || (element.value is Function), ast.currentPointer) - ast.currentPointer;
              if (ast.ast[ast.currentPointer + addOffset].value is FunctionFlowchart) {
                return _flowchartFunctionCall(ast, addOffset);
              }
              _predefinedFunctionCall(ast, addOffset);
              break;

            case "return":
              _functionReturn(ast);

              return currentElement;

            case "+n":
              ASTNode result = _unaryOperator(ast, unaryPlusOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            case "-n":
              ASTNode result = _unaryOperator(ast, unaryMinusOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            case "!n":
              ASTNode result = _unaryOperator(ast, booleanNotOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            case "~n":
              ASTNode result = _unaryOperator(ast, bitwiseNotOperator);
              ast.ast[ast.currentPointer] = result;
              break;

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

            case "<=":
              ASTNode result = _binaryOperator(ast, lessThanOrEqualOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            case ">":
              ASTNode result = _binaryOperator(ast, moreThanOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            case "<":
              ASTNode result = _binaryOperator(ast, lessThanOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            case "==":
              ASTNode result = _binaryOperator(ast, equalOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            case "!=":
              ASTNode result = _binaryOperator(ast, notEqualOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            case "&&":
              ASTNode result = _binaryOperator(ast, logicalAndOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            case "||":
              ASTNode result = _binaryOperator(ast, logicalOrOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            case "|":
              ASTNode result = _binaryOperator(ast, bitwiseOrOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            case "&":
              ASTNode result = _binaryOperator(ast, bitwiseAndOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            case "^":
              ASTNode result = _binaryOperator(ast, bitwiseXorOperator);
              ast.ast[ast.currentPointer] = result;
              break;

            default:
              throw Exception("Unknown Operator");
          }
        }
      }
    }
    
    List<ASTNode> results = _currentAST.map((e) => e.ast.isNotEmpty ? e.ast.single : ASTNode.empty()).toList();
    var element = currentElement.evaluate(topStack, results);
    _currentAST = [];
    return element;
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

    return ASTNode(ASTNodeType.literal, op.value!, op.value.runtimeType);
  }

  // TODO: Check whether the return value matched the function return type
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
    if (returnVal == null) {
      stack.removeFromCurrentPosition();

      return;
    }

    stack.ast[stack.currentPointer] = returnVal;
  }

  BaseElement _flowchartFunctionCall(_StackAST ast, int addOffset) {
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
  }

  void _predefinedFunctionCall(_StackAST ast, int addOffset) {
    Function function = ast.removeFromCurrentPosition(addOffset).value as Function;
    addOffset -= 1;

    List<ASTNode> arguments;
    arguments = ast.ast.sublist(ast.currentPointer + 1, ast.currentPointer + addOffset + 1);
    ast.ast.removeRange(ast.currentPointer + 1, ast.currentPointer + addOffset + 1);
    ast.offset -= addOffset;

    ASTNode? returnValue = function(arguments);
    returnValue == null ? ast.removeFromCurrentPosition() : ast.ast[ast.currentPointer] = returnValue;
  }

  ASTNode _unaryOperator(_StackAST ast, Function opFunc) {
    ASTNode node = ast.removeFromCurrentPosition(1);

    node = convertIdentifierToLiteral(node);
    ASTNode result = opFunc(node);

    return result;
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
    if (leftOp.value is String && rightOp.value is String) {
      result = (leftOp.value as String) + (rightOp.value as String);
    }
    else if (leftOp.value is num && rightOp.value is num) {
      result = (leftOp.value as num) + (rightOp.value as num);
    }
    else {
      throw Exception("Unexpected operands type. ${leftOp.valueType} and ${rightOp.valueType}");
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

  ASTNode? consoleOutput(List<ASTNode> output) {
    ASTNode node = output.single;
    dynamic value = node.value;
    if (node.type == ASTNodeType.identifier) {
      value = (value as Wrapper).value;
    }

    _consoleBuffer.add(value.toString());

    return null;
  }

  void clearConsole() {
    _consoleBuffer.clear();
  }

  ASTNode? inputConsole(List<ASTNode> params) {
    ASTNode node = params.first;
    if (node.type != ASTNodeType.identifier) {
      throw Exception("Input variable must be a variable");
    }

    Wrapper variable = node.value as Wrapper;
    _inputVariable = variable;

    if (params.length == 2) {
      consoleOutput([params.last]);
    }

    _expectingInput = true;

    return null;
  }

  void setInputBuffer(String input) {
    if (!_expectingInput) {
      return;
    }

    Wrapper inputVar = _inputVariable!;
    switch (inputVar.type) {
      case String:
        inputVar.value = input;
        break;

      case int:
        inputVar.value = int.parse(input);
        break;

      case double:
        inputVar.value = double.parse(input);
        break;

      case bool:
        inputVar.value = bool.parse(input);
        break;
    }

    _expectingInput = false;
    _inputVariable = null;
  }

  Memory get topStack => memoryStack.last;

  bool get isExpectingInput => _expectingInput;
  List<String> get outputBuffer => _consoleBuffer;
}