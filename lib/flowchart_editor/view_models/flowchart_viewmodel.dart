import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/flowchart_editor/view_models/flowchart_editor_viewmodel.dart';
import 'package:flutter/material.dart';

import '../models/flowchart.dart';

class FlowchartViewModel extends ChangeNotifier {
  Flowchart _flowchart;

  FlowchartViewModel(this._flowchart);

  void update(FlowchartEditorViewModel flowchartEditorViewModel) {
    _flowchart = flowchartEditorViewModel.currentFlowchart;

    notifyListeners();
  }

  void addNewElement(BaseElement newElement, String location) {
    _flowchart.addElement2(newElement, location);

    notifyListeners();
  }

  void removeElement(String location) {
    _flowchart.removeElement2(location);

    notifyListeners();
  }

  BaseElement? elementAt(String pos) {
    return _flowchart.elements2[pos];
  }

  int flowchartElementCount() {
    return _flowchart.elements2.length;
  }

  Flowchart get flowchart => _flowchart;
  set flowchart(Flowchart fl) {
    _flowchart = fl;

    notifyListeners();
  }
}