import 'package:code_chart/flowchart_editor/execution_environment/execution_environment.dart';
import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:flutter/material.dart';

import 'flowchart_editor_viewmodel.dart';

class ExecutionViewModel extends ChangeNotifier {
  ExecutionEnvironment? _environment;
  BaseElement? currentElement;

  ExecutionViewModel(this._environment);

  void update(FlowchartEditorViewModel vm) {
    var env = vm.mainProgram.runEnv;
    _environment = env;
    currentElement = _environment?.currentElement;

    notifyListeners();
  }

  ExecutionEnvironment? get environment => _environment;
  set environment(ExecutionEnvironment? env) {
    _environment = env;

    notifyListeners();
  }
}