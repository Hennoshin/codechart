import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/models/assignment_element.dart';
import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/flowchart_editor/models/branching_element.dart';
import 'package:code_chart/flowchart_editor/models/declaration_element.dart';
import 'package:code_chart/flowchart_editor/models/flowchart_program.dart';
import 'package:code_chart/flowchart_editor/models/function_call_element.dart';
import 'package:code_chart/flowchart_editor/models/function_flowchart.dart';
import 'package:code_chart/flowchart_editor/models/input_element.dart';
import 'package:code_chart/flowchart_editor/models/output_element.dart';
import 'package:code_chart/flowchart_editor/models/while_loop_element.dart';

import '../../flowchart_editor/models/flowchart.dart';

/* TODO: Currently only convert to C++, change it so it can convert based on a given template
    Use the same rule as parser? (Formal grammar)
 */
class ConvertedCodes {
  static const Map<DataType, String> typeMap = { DataType.integer: "int", DataType.real: "double", DataType.boolean: "bool", DataType.string: "string" };

  final FlowchartProgram program;
  late final List<String> sourceCode;

  ConvertedCodes(this.program) {
    List<String> codes = [];

    codes.add("#include <iostream>");
    codes.add("using namespace std;");
    codes.add("");

    for (var entry in program.functionTable.entries) {
      codes.add("${_evaluateFunctionDesc(entry.value)};");
    }

    codes.add("");
    codes.add("int main() {");

    List<String> indexes = program.mainFlowchart.elements2.keys.toList(growable: false);
    indexes.sort((str1, str2) => str1.compareTo(str2));
    _insertElements(program.mainFlowchart, codes, indexes, 1);

    codes.add("\treturn 0;");
    codes.add("}");

    codes.add("");
    codes.add("");

    for (var entry in program.functionTable.entries) {
      _evaluateFunctionFlowchart(codes, entry.value);
    }

    sourceCode = codes.toList(growable: false);

    print(sourceCode.join("\n"));
  }

  String _evaluateFunctionDesc(FunctionFlowchart function) {
    String returnType = function.returnType == null ? "void" : typeMap[function.returnType]!;
    List<String> params = function.argList.map((entry) => "${typeMap[entry.type]} ${entry.name}").toList();

    return "$returnType ${function.name}(${params.join(", ")})";
  }

  void _evaluateFunctionFlowchart(List<String> codes, FunctionFlowchart function) {
    codes.add("${_evaluateFunctionDesc(function)} {");
    List<String> indexes = function.elements2.keys.toList(growable: false);
    indexes.sort((str1, str2) => str1.compareTo(str2));
    _insertElements(function, codes, indexes, 1);
    codes.add("\treturn ${function.returnExpression};");
    codes.add("}");
  }

  void _insertElements(Flowchart flowchart, List<String> codes, List<String> keys, int tabCount, [String prefix = ""]) {

    String tab = "";
    for (int i = 0; i < tabCount; i += 1) {
      tab += "\t";
    }

    for (var key in keys.where((element) {
      List index = element.split(".");
      int count = index.length;

      return (count == 2 * tabCount - 1) && (element.startsWith(prefix));
    })) {
      Map<String,BaseElement> map = flowchart.elements2;

      if (map[key] is WhileLoopElement) {
        codes.add("${tab}while (${map[key]!}) {");
        _insertElements(flowchart, codes, keys, tabCount + 1, "$key.0.");
        codes.add("$tab}");
      }
      else if (map[key] is BranchingElement) {
        codes.add("${tab}if (${map[key]!}) {");
        _insertElements(flowchart, codes, keys, tabCount + 1, "$key.0.");
        codes.add("$tab}");
        codes.add("${tab}else {");
        _insertElements(flowchart, codes, keys, tabCount + 1, "$key.1.");
        codes.add("$tab}");
      }
      else {
        codes.add(_evaluateFlowchartElement(map[key]!, tabCount));
      }
    }
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

      case FunctionCallElement:
        return tab + _evaluateFunctionCallElement(element as FunctionCallElement);



      default:
        return tab;
    }
  }

  String _evaluateDeclarationElement(DeclarationElement element) {
    String str;

    str = "${typeMap[element.varType]!} ${element.baseExpr ?? ""};";

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

  String _evaluateFunctionCallElement(FunctionCallElement element) {
    return "${element.baseExpr};";
  }

  @override
  String toString() {
    return sourceCode.join("\n");
  }

}