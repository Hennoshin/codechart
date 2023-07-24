import 'package:code_chart/flowchart_editor/view_models/flowchart_editor_viewmodel.dart';
import 'package:flutter/material.dart';

class ConsoleViewModel extends ChangeNotifier {
  List<String>? _outputBuffer;
  int _bufferLength = 0;
  bool _expectingInput = false;

  ConsoleViewModel();

  void update(FlowchartEditorViewModel flowchartEditorViewModel) {
    List<String>? buffer = flowchartEditorViewModel.mainProgram.runEnv?.outputBuffer;
    bool expectInput = flowchartEditorViewModel.mainProgram.runEnv?.isExpectingInput ?? false;
    int length = buffer?.length ?? 0;

    if (length == _bufferLength && _expectingInput == expectInput) {
      return;
    }

    _outputBuffer = buffer;
    _bufferLength = length;
    _expectingInput = expectInput;
    notifyListeners();
  }

  List<String> get outputBuffer => _outputBuffer ?? [];
  bool get expectingInput => _expectingInput;
}