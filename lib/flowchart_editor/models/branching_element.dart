import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/execution_environment/memory.dart';
import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/utility/data_classes.dart';

import 'merging_element.dart';

class BranchingElement extends BaseElement {
  late BaseElement falseBranchNextElement;
  late BaseElement trueBranchNextElement;
  final MergingElement mergePoint;

  BranchingElement(super.expr) : mergePoint = MergingElement() {
   setDefault();
  }

  @override
  void setDefault() {
    falseBranchNextElement = mergePoint;
    trueBranchNextElement = mergePoint;
  }

  @override
  BaseElement evaluate(Memory stack, List<ASTNode> exprs) {
    if (exprs.length != 1) {
      throw Exception("Unexpected number of expression. Single expression is expected");
    }

    ASTNode expr = exprs.first;
    if (expr.type == ASTNodeType.operator) {
      throw Exception("Unexpected expression. Variable or literal is expected");
    }

    bool result;

    switch(expr.type) {
      case ASTNodeType.identifier:
        result = (expr.value as Wrapper<bool>).value!;
        break;

      case ASTNodeType.literal:
        result = expr.value as bool;
        break;

      default:
        assert(false, "This should not happen!");
        throw Exception("Unknown error. This should not happen");
    }

    return result ? trueBranchNextElement : falseBranchNextElement;
  }

  @override
  set nextElement(e) {
    super.nextElement = e;
    mergePoint.nextElement = e;
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

    expr = properties.first as String;
  }
}