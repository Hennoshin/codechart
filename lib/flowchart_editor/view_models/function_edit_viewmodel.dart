import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/view_models/commons/error_reporting_viewmodel.dart';
import 'package:flutter/cupertino.dart';

import '../models/function_flowchart.dart';

class FunctionEditViewModel extends ChangeNotifier with ErrorReportingViewModel {
  final FunctionFlowchart? functionFlowchart;
  final List<FunctionArg> functionParameters;

  DataType? _returnType;

  FunctionEditViewModel([this.functionFlowchart]) : _returnType = functionFlowchart?.returnType, functionParameters = [
    for (var param in functionFlowchart?.argList ?? []) FunctionArg(param.name, param.type, param.isArray)
  ];

  void addFunctionParam(String varName, DataType type, bool isArray) {
    functionParameters.add(FunctionArg(varName, type, isArray));

    clearErrorAndNotify();
  }

  void editFunctionParam(int index, String varName, DataType type, bool isArray) {
    var param = functionParameters[index];
    param.name = varName;
    param.type = type;
    param.isArray = isArray;

    clearErrorAndNotify();
  }

  void deleteFunctionParam(int index) {
    functionParameters.removeAt(index);

    clearErrorAndNotify();
  }

  void swapFunctionParam(int srcIndex, int dstIndex) {
    var temp = functionParameters[dstIndex];
    functionParameters[dstIndex] = functionParameters[srcIndex];
    functionParameters[srcIndex] = temp;

    clearErrorAndNotify();
  }

  DataType? get returnType => _returnType;
  set returnType(type) {
    _returnType = type;

    clearErrorAndNotify();
  }

}