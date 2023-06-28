import 'package:code_chart/flowchart_editor/models/assignment_element.dart';
import 'package:code_chart/flowchart_editor/models/branching_element.dart';
import 'package:code_chart/flowchart_editor/models/declaration_element.dart';
import 'package:code_chart/flowchart_editor/models/function_call_element.dart';
import 'package:code_chart/flowchart_editor/models/input_element.dart';
import 'package:code_chart/flowchart_editor/models/output_element.dart';
import 'package:code_chart/flowchart_editor/models/while_loop_element.dart';
import 'package:code_chart/flowchart_editor/views/element/branching_element_edit_view.dart';
import 'package:code_chart/flowchart_editor/views/element/declaration_element_edit_view.dart';
import 'package:code_chart/flowchart_editor/views/element/function_call_element_edit_view.dart';
import 'package:code_chart/flowchart_editor/views/element/input_element_edit_view.dart';
import 'package:code_chart/flowchart_editor/views/element/output_element_edit_view.dart';
import 'package:code_chart/flowchart_editor/views/element/while_loop_element_edit_view.dart';
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
    if (element is WhileLoopElement) {
      return WhileLoopElementEditView(element: element);
    }
    if (element is BranchingElement) {
      return BranchingElementEditView(element: element);
    }
    if (element is FunctionCallElement) {
      return FunctionCallElementEditView(element: element);
    }

    return null;
  }
}