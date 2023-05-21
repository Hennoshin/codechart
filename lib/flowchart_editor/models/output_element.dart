import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
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
    if (exprs.length != 1) {
      throw Exception("Unexpected number of expressions");
    }

    var expression = exprs.single;
    dynamic value = expression.value;
    if (expression.type == ASTNodeType.identifier) {
      value = (value as Wrapper).value;
    }

    stack.setHiddenData("output_buffer", value.toString());

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

}