import 'package:code_chart/flowchart_editor/models/assignment_element.dart';
import 'package:code_chart/flowchart_editor/models/declaration_element.dart';
import 'package:code_chart/flowchart_editor/models/input_element.dart';
import 'package:code_chart/flowchart_editor/models/output_element.dart';
import 'package:code_chart/flowchart_editor/views/element/declaration_element_edit_view.dart';
import 'package:code_chart/flowchart_editor/views/element/input_element_edit_view.dart';
import 'package:code_chart/flowchart_editor/views/element/output_element_edit_view.dart';
import 'package:flutter/material.dart';

import '../../models/base_element.dart';
import 'assignment_element_edit_view.dart';

class ElementEditViewFactory {
  const ElementEditViewFactory();

  @factory
  Widget? createElementEditView(BaseElement element) {
    if (element is DeclarationElement) {
      return DeclarationElementEditView(element: element);
    }
    if (element is AssignmentElement) {
      return AssignmentElementEditView(element: element);
    }
    if (element is OutputElement) {
      return OutputElementEditView(element: element);
    }
    if (element is InputElement) {
      return InputElementEditView(element: element);
    }

    return null;
  }
}