import 'package:code_chart/flowchart_editor/view_models/flowchart_editor_viewmodel.dart';
import 'package:flutter/material.dart';

class ConsoleViewModel extends ChangeNotifier {
  List<String>? _outputBuffer;
  int _bufferLength = 0;

  ConsoleViewModel();

  void update(FlowchartEditorViewModel flowchartEditorViewModel) {
    List<String>? buffer = flowchartEditorViewModel.mainProgram.runEnv?.outputBuffer;
    int length = buffer?.length ?? 0;

    if (length == _bufferLength) {
      return;
    }

    _outputBuffer = buffer;
    _bufferLength = length;
    notifyListeners();
  }

  List<String> get outputBuffer => _outputBuffer ?? [];
}