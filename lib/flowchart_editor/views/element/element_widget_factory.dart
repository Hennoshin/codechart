import 'package:code_chart/flowchart_editor/models/branching_element.dart';
import 'package:code_chart/flowchart_editor/models/function_call_element.dart';
import 'package:code_chart/flowchart_editor/models/terminal_element.dart';
import 'package:code_chart/flowchart_editor/models/while_loop_element.dart';
import 'package:code_chart/flowchart_editor/views/element/assignment_element_widget.dart';
import 'package:code_chart/flowchart_editor/views/element/branching_element_widget.dart';
import 'package:code_chart/flowchart_editor/views/element/declaration_element_widget.dart';
import 'package:code_chart/flowchart_editor/views/element/element_widget.dart';
import 'package:code_chart/flowchart_editor/views/element/function_call_element_widget.dart';
import 'package:code_chart/flowchart_editor/views/element/input_element_widget.dart';
import 'package:code_chart/flowchart_editor/views/element/merge_element_widget.dart';
import 'package:code_chart/flowchart_editor/views/element/output_element_widget.dart';
import 'package:code_chart/flowchart_editor/views/element/terminal_element_widget.dart';
import 'package:code_chart/flowchart_editor/views/element/while_loop_element_widget.dart';
import 'package:code_chart/flowchart_editor/views/element/while_loop_filler_widget.dart';
import 'package:flutter/material.dart';

import '../../models/assignment_element.dart';
import '../../models/base_element.dart';
import '../../models/declaration_element.dart';
import '../../models/input_element.dart';
import '../../models/output_element.dart';

class ElementWidgetFactory {
  const ElementWidgetFactory();

  @factory
  Widget? createElementWidget(BaseElement element, String positionIndex) {
    if (element is TerminalElement) {
      return TerminalElementWidget(positionIndex: positionIndex);
    }
    if (element is DeclarationElement) {
      return DeclarationElementWidget(positionIndex: positionIndex);
    }
    if (element is AssignmentElement) {
      return AssignmentElementWidget(positionIndex: positionIndex);
    }
    if (element is OutputElement) {
      return OutputElementWidget(positionIndex: positionIndex);
    }
    if (element is InputElement) {
      return InputElementWidget(positionIndex: positionIndex);
    }
    if (element is FunctionCallElement) {
      return FunctionCallElementWidget(positionIndex: positionIndex);
    }
    if (element is WhileLoopElement) {
      return Column(
        children: <Widget>[
          WhileLoopElementWidget(positionIndex: positionIndex),
          const Expanded(
            child: WhileLoopFillerWidget(),
          )
        ],
      );
    }
    if (element is BranchingElement) {
      return Column(
        children: <Widget>[
          BranchingElementWidget(positionIndex: positionIndex),
          const Expanded(child: SizedBox()),
          const MergeElementWidget()
        ],
      );
    }

    return null;
  }
}