import 'package:code_chart/flowchart_editor/execution_environment/execution_environment.dart';
import 'package:flutter/material.dart';

class ExecutionViewModel extends ChangeNotifier {
  ExecutionEnvironment? environment;

  ExecutionViewModel(this.environment);

}