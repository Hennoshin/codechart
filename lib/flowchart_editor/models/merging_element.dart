import 'package:code_chart/flowchart_editor/execution_environment/memory.dart';
import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/utility/data_classes.dart';

class MergingElement extends BaseElement {
  MergingElement() : super.empty();

  @override
  BaseElement evaluate(Memory stack, List<ASTNode> exprs) {
    return nextElement;
  }

  @override
  List<String?> get expr => [];

  @override
  void setProperties(List properties) {
    throw UnsupportedError("Call to this method should not be performed");
  }
}