import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:flutter/material.dart';

import '../models/flowchart.dart';

class FlowchartViewModel extends ChangeNotifier {
  Flowchart _flowchart;

  FlowchartViewModel(this._flowchart);

  void addNewElement(BaseElement newElement, String location) {
    _flowchart.addElement2(newElement, location);

    notifyListeners();
  }

  void removeElement(String location) {
    _flowchart.removeElement2(location);

    notifyListeners();
  }

  Flowchart get flowchart => _flowchart;
  set flowchart(Flowchart fl) {
    _flowchart = fl;

    notifyListeners();
  }
}