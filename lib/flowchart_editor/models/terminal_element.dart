import 'dart:convert';

import 'package:code_chart/flowchart_editor/execution_environment/memory.dart';
import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/utility/data_classes.dart';

class TerminalElement extends BaseElement {
  final bool _isEndTerminal;
  String? placeholder;

  TerminalElement.start(this.placeholder) : _isEndTerminal = false, super.empty();
  TerminalElement.end(this.placeholder, [String? exp]) : _isEndTerminal = true, super(exp);

  @override
  BaseElement evaluate(Memory stack, List<ASTNode> exprs) {
    return nextElement;
  }

  @override
  List<String?> get exprList => _isEndTerminal ? ["return ${baseExpr ?? ""}"] : [];
  @override
  BaseElement get nextElement => _isEndTerminal ? this : super.nextElement;

  /// Set properties for the assignment element
  /// First [properties] accepts [String] as the return expression
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
  String toString() {
    return placeholder ?? "Terminal";
  }

  @override
  TerminalElement copyWith() {
    var newElement = _isEndTerminal ? TerminalElement.end(placeholder, baseExpr) : TerminalElement.start(placeholder);
    newElement.nextElement = nextElement;

    return newElement;
  }

  @override
  Map<String, dynamic> toJson() {
    return {"type": 7, "isEndTerminal": _isEndTerminal, "expression": baseExpr, "placeholder": placeholder};
  }
}