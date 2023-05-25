import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/models/assignment_element.dart';
import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/flowchart_editor/models/branching_element.dart';
import 'package:code_chart/flowchart_editor/models/declaration_element.dart';
import 'package:code_chart/flowchart_editor/models/flowchart_program.dart';
import 'package:code_chart/flowchart_editor/view_models/flowchart_viewmodel.dart';
import 'package:flutter/material.dart';

import '../models/flowchart.dart';
import '../models/output_element.dart';

class FlowchartEditorViewModel extends ChangeNotifier {
  FlowchartProgram mainProgram;
  Flowchart currentFlowchart;
  String programName;
  bool toggle = true;
  int elementSelectIndex = 0;
  String addElementIndex = "1";

  int _selectedToolsIndex = 0;

  int get selectedToolsIndex => _selectedToolsIndex;
  set selectedToolsIndex(i) {
    _selectedToolsIndex = i;

    notifyListeners();
  }

  FlowchartEditorViewModel(this.mainProgram) :
        currentFlowchart = mainProgram.mainFlowchart,
        programName = mainProgram.programName;

  void toggleName() {
    if (toggle) {
      programName = "Hidden Name";
    }
    else {
      programName = mainProgram.programName;
    }

    toggle = !toggle;

    notifyListeners();
  }

  void setAddElementSelect(String index) {
    addElementIndex = index;
  }

  /// TODO: Move this logic to a [BaseElement] factory and to [FlowchartViewModel]
  void addElement(int elementType) {
    BaseElement newElement;
    switch (elementType) {
      case 0:
        newElement = DeclarationElement(null, false, DataType.integer);
        break;

      case 1:
        newElement = AssignmentElement(null, null);
        break;

      case 2:
        newElement = OutputElement(null);
        break;
      default:
        throw Exception("Unknown type");
    }

    currentFlowchart.addElement2(newElement, addElementIndex);

    notifyListeners();
  }

  void removeElement(String index) {
    currentFlowchart.removeElement(index);

    notifyListeners();
  }

  void stepRunFlowchart() {
    mainProgram.stepRunFlowchart();

    notifyListeners();
  }

  void stopFlowchart() {
    mainProgram.stopFlowchart();

    notifyListeners();
  }

  BaseElement? currentRunElement() {
    return mainProgram.runEnv?.currentElement;
  }

  bool get isFlowchartRunning => mainProgram.isRunning;
}