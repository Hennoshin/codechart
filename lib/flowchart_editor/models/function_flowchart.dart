import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/models/flowchart.dart';
import 'package:code_chart/flowchart_editor/models/terminal_element.dart';

class FunctionArg {
  String name;
  DataType type;
  bool isArray;

  FunctionArg(this.name, this.type, this.isArray);
}

class FunctionFlowchart extends Flowchart {
  final List<FunctionArg> _argList = [];
  DataType? _returnType;
  String _name;

  FunctionFlowchart(this._name) : super(_name);

  void addFunctionParameter(String name, DataType type, [bool isArray = false]) {
    if (argList.indexWhere((element) => element.name == name) != -1) {
      throw Exception("Failed to add new parameter, the name already existed");
    }
    argList.add(FunctionArg(name, type, isArray));
  }

  void changeFunctionParameter(int index, String newName, DataType newType, bool newIsArray) {
    FunctionArg parameter = argList[index];

    int existingIndex = argList.indexWhere((element) => element.name == newName);
    if (existingIndex != -1 && existingIndex != index) {
      throw Exception("Failed to change parameter, the name already existed");
    }

    parameter.name = newName;
    parameter.type = newType;
    parameter.isArray = newIsArray;
  }

  String get name => _name;
  set name(String n) {
    _name = n;

    String index = (elements2.keys.toList()..sort((str1, str2) => str1.compareTo(str2))).first;
    (elements2[index]! as TerminalElement).placeholder = n;
  }

  DataType? get returnType => _returnType;
  set returnType(type) {
    if (type == null) {
      returnExpression = null;
    }

    _returnType = type;
  }

  String get returnExpression {
    String index = (elements2.keys.toList()..sort((str1, str2) => str1.compareTo(str2))).last;

    return elements2[index]!.baseExpr ?? "";
  }
  set returnExpression(String? expr) {
    if (_returnType == null) {
      return;
    }

    String index = (elements2.keys.toList()..sort((str1, str2) => str1.compareTo(str2))).last;

    elements2[index]!.baseExpr = expr;
  }

  List<FunctionArg> get argList => _argList;
  set argList(List<FunctionArg> lst) {
    argList.clear();
    for (FunctionArg arg in lst) {
      addFunctionParameter(arg.name, arg.type, arg.isArray);
    }
  }
}