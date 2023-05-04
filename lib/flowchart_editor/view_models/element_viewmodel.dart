import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:flutter/material.dart';

class ElementViewModel extends ChangeNotifier {
  BaseElement currentElement;
  String index;

  ElementViewModel(this.currentElement, this.index);
}