import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/utility/data_classes.dart';
import 'package:flutter/material.dart';
import '../execution_environment/memory.dart';

abstract class BaseElement {
  @protected
  String? _expr;
  late BaseElement _nextElement;

  BaseElement(this._expr);
  BaseElement.empty();

  /// Set properties of the current element
  /// Each subclass overrides this method based on the properties/object variable each class has
  /// Alternative to set each properties individually
  /// Also adds checks to make sure the arguments are valid
  void setProperties(List<dynamic> properties);
  BaseElement evaluate(Memory stack, List<ASTNode> exprs);
  void setDefault() {
    return;
  }

  List<String?> get expr => [_expr];
  BaseElement get nextElement => _nextElement;

  set expr(exp) => _expr = exp;
  set nextElement(el) => _nextElement = el;
}