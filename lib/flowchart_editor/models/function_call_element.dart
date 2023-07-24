import 'dart:convert';

import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/execution_environment/memory.dart';
import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/utility/data_classes.dart';

import 'merging_element.dart';

class FunctionCallElement extends BaseElement {
  FunctionCallElement(super.expr);

  FunctionCallElement.fromJson(Map<String, dynamic> json) : super(json["expression"]);

  @override
  BaseElement evaluate(Memory stack, List<ASTNode> exprs) {
    return nextElement;
  }

  /// Set properties for the assignment element
  /// First [properties] accepts [String] as the if-else expression
  @override
  void setProperties(List<dynamic> properties) {
    if (properties.length != 1) {
      throw Exception("Unexpected number of properties for this element, expected 2, got ${properties.length} instead");
    }
    if (properties.first is! String) {
      throw Exception("Expected String for the properties");
    }

    baseExpr = properties.first as String;
  }

  @override
  List<String?> get exprList => [baseExpr];

  @override
  FunctionCallElement copyWith() {
    var newElement = FunctionCallElement(baseExpr);
    newElement.nextElement = nextElement;

    return newElement;
  }

  @override
  String toString() {
    return baseExpr ?? "Function Call";
  }

  @override
  Map<String, dynamic> toJson() {
    return {"type": 8, "expression": baseExpr};
  }
}