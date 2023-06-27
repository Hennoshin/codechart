import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/models/assignment_element.dart';
import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/flowchart_editor/models/declaration_element.dart';
import 'package:code_chart/flowchart_editor/models/flowchart_program.dart';
import 'package:code_chart/flowchart_editor/models/input_element.dart';
import 'package:code_chart/flowchart_editor/models/output_element.dart';

/* TODO: Currently only convert to C++, change it so it can convert based on a given template
    Use the same rule as parser? (Formal grammar)
 */
class ConvertedCodes {
  final FlowchartProgram program;
  late final List<String> sourceCode;

  ConvertedCodes(this.program) {
    List<String> codes = [];

    codes.add("#include <iostream>");
    codes.add("using namespace std;");
    codes.add("");
    codes.add("");
    codes.add("int main() {");

    List<String> indexes = program.mainFlowchart.elements2.keys.toList(growable: false);
    indexes.sort((str1, str2) => str1.compareTo(str2));
    for (var entry in indexes) {
      Map map = program.mainFlowchart.elements2;

      codes.add(_evaluateFlowchartElement(map[entry]!, 1));
    }

    codes.add("\treturn 0;");
    codes.add("}");

    sourceCode = codes.toList(growable: false);
  }

  String _evaluateFlowchartElement(BaseElement element, int tabCount) {
    String tab = "";
    for (int i = 0; i < tabCount; i += 1) {
      tab += "\t";
    }

    switch (element.runtimeType) {
      case DeclarationElement:
        return tab + _evaluateDeclarationElement(element as DeclarationElement);

      case AssignmentElement:
        return tab + _evaluateAssignmentElement(element as AssignmentElement);

      case OutputElement:
        return tab + _evaluateOutputElement(element as OutputElement);

      case InputElement:
        return tab + _evaluateInputElement(element as InputElement);

      default:
        return tab;
    }
  }

  String _evaluateDeclarationElement(DeclarationElement element) {
    String str;

    Map<DataType, String> map = { DataType.integer: "int", DataType.real: "double", DataType.boolean: "bool", DataType.string: "string" };
    str = "${map[element.varType]!} ${element.baseExpr ?? ""};";

    return str;
  }

  String _evaluateAssignmentElement(AssignmentElement element) {
    return "${element.assignmentExpr} = ${element.baseExpr};";
  }

  String _evaluateOutputElement(OutputElement element) {
    return "cout << (${element.baseExpr}) << endl;";
  }

  String _evaluateInputElement(InputElement element) {
    return "cin >> ${element.baseExpr};";
  }

}