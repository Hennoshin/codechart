import 'package:code_chart/flowchart_editor/execution_environment/execution_environment.dart';
import 'package:code_chart/flowchart_editor/models/flowchart.dart';
import 'package:code_chart/flowchart_editor/models/function_flowchart.dart';

class FlowchartProgram {
  String programName;
  Flowchart mainFlowchart;
  Map<String, FunctionFlowchart> functionTable = {};
  ExecutionEnvironment? runEnv;

  FlowchartProgram(this.programName) : mainFlowchart = Flowchart("Main");
  FlowchartProgram.create(this.programName, this.mainFlowchart);

  void addFunction(String functionName, FunctionFlowchart func) {
    if (functionTable.containsKey(functionName)) {
      throw Exception("Function already exists");
    }

    functionTable[functionName] = func;
  }

  void removeFunction(String functionName) {
    if (!functionTable.containsKey(functionName)) {
      throw Exception("No function by that name");
    }

    functionTable.remove(functionName);
  }

  void runFlowchart() {
    runEnv = ExecutionEnvironment(mainFlowchart.startElement, functionTable);
    bool hasElement;
    do {
      hasElement = runEnv!.stepRunElement();
    } while (hasElement);

    stopFlowchart();
  }

  void stepRunFlowchart() {
    runEnv = ExecutionEnvironment(mainFlowchart.startElement, functionTable);
  }

  void stopFlowchart() {
    runEnv = null;
  }

  bool get isRunning => (runEnv != null);
}