import 'package:code_chart/flowchart_editor/models/assignment_element.dart';
import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/flowchart_editor/models/branching_element.dart';
import 'package:code_chart/flowchart_editor/models/declaration_element.dart';
import 'package:code_chart/flowchart_editor/models/function_call_element.dart';
import 'package:code_chart/flowchart_editor/models/input_element.dart';
import 'package:code_chart/flowchart_editor/models/output_element.dart';
import 'package:code_chart/flowchart_editor/models/terminal_element.dart';
import 'package:code_chart/flowchart_editor/models/while_loop_element.dart';
import 'package:flutter/foundation.dart';

class ElementFactory {
  static final ElementFactory instance = ElementFactory();

  @factory
  BaseElement createElementFromJson(Map<String, dynamic> json) {
    switch (json["type"]! as int) {
      case 1:
        return DeclarationElement.fromJson(json);

      case 2:
        return AssignmentElement.fromJson(json);

      case 3:
        return BranchingElement.fromJson(json);

      case 4:
        return WhileLoopElement.fromJson(json);

      case 5:
        return InputElement.fromJson(json);

      case 6:
        return OutputElement.fromJson(json);

      case 7:
        return TerminalElement.fromJson(json);

      case 8:
        return FunctionCallElement.fromJson(json);

      default:
        throw Exception("Unable to create new Element, unknown type, type ID is: ${json["type"]}");
    }
  }

}