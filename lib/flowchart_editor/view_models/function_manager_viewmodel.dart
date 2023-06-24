import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/models/flowchart_program.dart';
import 'package:code_chart/flowchart_editor/models/function_flowchart.dart';
import 'package:code_chart/flowchart_editor/view_models/commons/error_reporting_viewmodel.dart';
import 'package:flutter/material.dart';

class FunctionManagerViewModel extends ChangeNotifier with ErrorReportingViewModel {
  final FlowchartProgram flowchartProgram;

  FunctionManagerViewModel(this.flowchartProgram);

  void addNewFunction(String functionName, DataType? returnType, String returnExpression, List<FunctionArg> parameters) {
    if (functionName == "") {
      registerAndNotifyError("Function name cannot be empty");

      return;
    }

    try {
      FunctionFlowchart functionFlowchart = FunctionFlowchart(functionName);
      functionFlowchart.returnType = returnType;
      functionFlowchart.returnExpression = returnExpression;
      functionFlowchart.argList = parameters;

      flowchartProgram.addFunction(functionName, functionFlowchart);
    }
    catch (e) {
      registerAndNotifyError(e.toString());

      return;
    }

    clearErrorAndNotify();
  }

  void changeFunction(String functionName, String newName, DataType? newType, String newReturn, List<FunctionArg> newParam) {
    if (newName == "") {
      registerAndNotifyError("Function name cannot be empty");

      return;
    }

    try {
      flowchartProgram.changeFunctionName(functionName, newName);
      FunctionFlowchart functionFlowchart = flowchartProgram.functionTable[newName]!;
      functionFlowchart.returnType = newType;
      functionFlowchart.returnExpression = newReturn;
      functionFlowchart.argList = newParam;
    }
    catch (e) {
      registerAndNotifyError(e.toString());
    }

    clearErrorAndNotify();
  }

  void changeFunctionName(String functionName, String newName) {
    if (newName == "") {
      registerAndNotifyError("Function name cannot be empty");

      return;
    }

    try {
      flowchartProgram.changeFunctionName(functionName, newName);
    }
    catch (e) {
      registerAndNotifyError(e.toString());
    }

    clearErrorAndNotify();
  }

  void deleteFunction(String functionName) {
    flowchartProgram.functionTable.remove(functionName);

    clearErrorAndNotify();
  }
}