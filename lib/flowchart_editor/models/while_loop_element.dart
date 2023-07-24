import 'dart:convert';

import 'branching_element.dart';

class WhileLoopElement extends BranchingElement {
  WhileLoopElement(super.expr);

  WhileLoopElement.fromJson(Map<String, dynamic> json) : this(json["expression"]);

  @override
  void setDefault() {
    trueBranchNextElement = this;
  }

  @override
  set nextElement(e) {
    super.falseBranchNextElement = e;
    super.nextElement = e;
  }

  @override
  set falseBranchNextElement(e) {
    nextElement = e;
  }

  @override
  WhileLoopElement copyWith() {
    var newElement = WhileLoopElement(baseExpr);
    newElement.nextElement = nextElement;

    return newElement;
  }

  @override
  String toString() {
    return baseExpr ?? "While Loop";
  }

  @override
  Map<String, dynamic> toJson() {
    return {"type": 4, "expression": baseExpr};
  }
}