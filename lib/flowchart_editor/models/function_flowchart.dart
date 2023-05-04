import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/models/flowchart.dart';

class FunctionArg {
  String name;
  DataType type;
  bool isArray;

  FunctionArg(this.name, this.type, this.isArray);
}

class FunctionFlowchart extends Flowchart {
  List<FunctionArg> argList = [];
  DataType? returnType;
  String name;

  FunctionFlowchart(this.name) : super(name);

  void setReturn(String expr) {
    elements[1].expr = "return $expr";
  }
}