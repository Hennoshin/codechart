import 'package:code_chart/flowchart_editor/execution_environment/memory.dart';
import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/utility/data_classes.dart';

/*
 * Who's handling the output? Execution environment?
 */
class OutputElement extends BaseElement {
  OutputElement(super.expr);

  @override
  BaseElement evaluate(Memory stack, List<ASTNode> exprs) {
    return nextElement;
  }

  @override
  void setProperties(List properties) {
    if (properties.length != 1) {
      throw Exception("Unexpected number of properties for this element, expected 1, got ${properties.length} instead");
    }
    if (properties.single is! String) {
      throw Exception("Expecting String as the first properties");
    }

    expr = properties.single as String;
  }

  @override
  List<String?> get expr => ["output(${super.expr.single})"];

  @override
  String toString() {
    return super.expr.single ?? "Output";
  }
}