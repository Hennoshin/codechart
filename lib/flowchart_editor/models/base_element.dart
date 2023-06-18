import 'package:code_chart/utility/data_classes.dart';
import 'package:flutter/material.dart';
import '../execution_environment/memory.dart';

// TODO: Consider putting nextStructureElement to get next element in the structure, not execution, such as after the element's scope
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

  BaseElement copyWith();

  String? get baseExpr => _expr;
  List<String?> get exprList;
  BaseElement get nextElement => _nextElement;

  set baseExpr(exp) => _expr = exp;
  set nextElement(el) => _nextElement = el;
}