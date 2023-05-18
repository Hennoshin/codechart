import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/view_models/flowchart_editor_viewmodel.dart';
import 'package:flutter/material.dart';

import '../execution_environment/memory.dart';

class MemoryViewModel extends ChangeNotifier {
  List<Memory> memory = [];

  String? memoryError;

  void update(FlowchartEditorViewModel vm) {
    List<Memory> mList = vm.mainProgram.runEnv?.memoryStack.toList() ?? [];
    memory = mList;

    notifyListeners();
  }

  void changeVariableValue<T>(int stackIndex, String varName, T newValue) {
    try {
      Wrapper wrapper = memory[stackIndex].getData(varName);
      memory[stackIndex].assignVariable(wrapper, newValue);
    } catch (e) {
      memoryError = e.toString();
    }

    notifyListeners();
  }

  void dismissError() {
    memoryError = null;
  }
}