import 'package:code_chart/flowchart_editor/execution_environment/memory.dart';

import 'package:code_chart/utility/data_classes.dart';

import 'base_element.dart';

class InputElement extends BaseElement {
  String prompt = "";

  InputElement(super.expr);

  @override
  List<String?> get exprList => ["input($baseExpr${prompt.isNotEmpty ? ", $prompt" : ""})"];

  @override
  BaseElement evaluate(Memory stack, List<ASTNode> exprs) {
    return nextElement;
  }

  @override
  void setProperties(List properties) {
    if (properties.length != 2) {
      throw Exception("Unexpected number of properties for this element, expected 2, got ${properties.length} instead");
    }
    if (properties[0] is! String) {
      throw Exception("Expecting String as the first properties");
    }
    if (properties[1] is! String) {
      throw Exception("Expecting String as the second properties");
    }

    baseExpr = properties[0] as String;
    prompt = properties[1] as String;
  }

  @override
  String toString() {
    return baseExpr != null ? "Input: $baseExpr" : "Input Element";
  }
}