import 'dart:math';

import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/execution_environment/memory.dart';
import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/utility/data_classes.dart';

class AssignmentElement extends BaseElement {
  String? _assignmentExpr;

  AssignmentElement(String? baseExpr, this._assignmentExpr) : super(baseExpr);

  /*
   * Evaluate variable assignment
   * leftOp = rightOp
   * exprs[0] = leftOp
   * exprs[1] = rightOp
   *
   * If operand is variable, wrapper is expected
   */
  @override
  BaseElement evaluate(Memory stack, List<ASTNode> exprs) {
    if (exprs.length != 2) {
      throw Exception("Unexpected number of expression");
    }

    if (exprs.first.type != ASTNodeType.identifier) {
      throw Exception("Unexpected left operand expression. Variable is expected.");
    }
    if (exprs.last.type == ASTNodeType.operator) {
      throw Exception("Unexpected right operand expression.");
    }

    Wrapper leftOp = exprs.first.value as Wrapper;
    var rightOp = exprs.last;

    stack.assignVariable(leftOp, rightOp.value);

    return nextElement;
  }

  @override
  List<String?> get exprList => [_assignmentExpr, baseExpr];
  String? get assignmentExpr => _assignmentExpr;

  set assignmentExpr(exp) => _assignmentExpr = exp;

  /// Set properties for the assignment element
  /// First [properties] accepts [String] as the assignment expression, left operand
  /// Second [properties] accepts [String] as the assignee expression, right operand
  @override
  void setProperties(List<dynamic> properties) {
    if (properties.length != 2) {
      throw Exception("Unexpected number of properties for this element, expected 2, got ${properties.length} instead");
    }
    if (properties.first is! String) {
      throw Exception("Expected String for the properties");
    }
    if (properties.last is! String) {
      throw Exception("Expected String for the properties");
    }

    assignmentExpr = properties.first as String;
    baseExpr = properties.last as String;
  }

  @override
  String toString() {
    String str = (_assignmentExpr ?? "") + (baseExpr ?? "");
    return str != "" ? str : "Assignment";
  }
}