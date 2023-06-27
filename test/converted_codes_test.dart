import 'package:code_chart/code_converter/model/converted_codes.dart';
import 'package:code_chart/flowchart_editor/models/assignment_element.dart';
import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/flowchart_editor/models/branching_element.dart';
import 'package:code_chart/flowchart_editor/models/flowchart_program.dart';
import 'package:code_chart/flowchart_editor/models/terminal_element.dart';
import 'package:code_chart/flowchart_editor/models/while_loop_element.dart';
import 'package:test/test.dart';
import 'package:code_chart/flowchart_editor/models/flowchart.dart';

import 'package:collection/collection.dart';

void main() {
  late FlowchartProgram program;
  late Flowchart flowchart;
  setUp(() {
    program = FlowchartProgram("Test Program");
    flowchart = program.mainFlowchart;
  });

  test("Test code creation is valid", () {
    ConvertedCodes codes = ConvertedCodes(program);

    print(codes.sourceCode);
    expect(const DeepCollectionEquality().equals(codes.sourceCode, [
      "#include <iostream>",
      "using namespace std;",
      "",
      "",
      "int main() {",
      "\t",
      "\t",
      "\treturn 0;",
      "}"
    ]), true);
  });

  test("Test adding new element", () {
    BaseElement element = AssignmentElement("\"Hello\"", "str");
    flowchart.addElement2(element, "1");

    ConvertedCodes codes = ConvertedCodes(program);

    print(codes.sourceCode);
    expect(const DeepCollectionEquality().equals(codes.sourceCode, [
      "#include <iostream>",
      "using namespace std;",
      "",
      "",
      "int main() {",
      "\t",
      "\tstr = \"Hello\";",
      "\t",
      "\treturn 0;",
      "}"
    ]), true);
  });

  /*
  test("Test deleting element", () {
    BaseElement element = AssignmentElement(null, null);
    flowchart.addElement2(element, "1");
    flowchart.removeElement2("1");

    expect(flowchart.elements2.length, 2);
    expect(flowchart.elements2["0"] is TerminalElement, true);
    expect(flowchart.elements2["1"] is TerminalElement, true);
    expect(flowchart.elements2["0"]!.nextElement, flowchart.elements2["1"]);
  });

  test("Test adding branching element", () {
    BaseElement element1 = BranchingElement(null);
    BaseElement element2 = AssignmentElement(null, null);

    flowchart.addElement2(element1, "1");
    flowchart.addElement2(element2, "1.0.1");

    expect(flowchart.elements2.length, 4);
    expect((flowchart.elements2["1"]!.nextElement), flowchart.elements2["2"]);
    expect((flowchart.elements2["1"]! as BranchingElement).trueBranchNextElement, element2);
    expect(flowchart.elements2["1.0.1"], element2);
  });

  test("Test adding multiple branching element", () {
    BaseElement element1 = BranchingElement(null);
    BaseElement element2 = BranchingElement(null);
    BaseElement element3 = AssignmentElement(null, null);

    flowchart.addElement2(element1, "1");
    flowchart.addElement2(element2, "1.0.1");
    expect(() => flowchart.addElement2(element3, "1.0.1.1.1"), returnsNormally);

    expect(flowchart.elements2.length, 5);
    expect((flowchart.elements2["1"]!.nextElement), flowchart.elements2["2"]);
    expect((flowchart.elements2["1"]! as BranchingElement).trueBranchNextElement, element2);
    expect((flowchart.elements2["1.0.1"]! as BranchingElement).falseBranchNextElement, element3);
  });

  test("Test adding a while loop element", () {
    BaseElement element1 = WhileLoopElement(null);
    BaseElement element2 = AssignmentElement(null, null);
    BaseElement element3 = AssignmentElement(null, null);

    flowchart.addElement2(element1, "1");
    expect(() => flowchart.addElement2(element2, "1.0.1"), returnsNormally);
    expect(() => flowchart.addElement2(element3, "2"), returnsNormally);

    expect(flowchart.elements2.length, 5);
    expect(flowchart.elements2["1"]!.nextElement, flowchart.elements2["2"]!);
    expect((flowchart.elements2["1"]! as WhileLoopElement).trueBranchNextElement, flowchart.elements2["1.0.1"]!);
    expect((flowchart.elements2["1"]! as WhileLoopElement).falseBranchNextElement, flowchart.elements2["2"]!);
    expect(flowchart.elements2["1.0.1"]!.nextElement, flowchart.elements2["1"]!);
  });

  test("Test delete element", () {
    BaseElement element1 = BranchingElement(null);
    BaseElement element2 = BranchingElement(null);
    BaseElement element3 = AssignmentElement(null, null);
    BaseElement element4 = AssignmentElement(null, null);

    flowchart.addElement2(element1, "1");
    flowchart.addElement2(element2, "1.0.1");
    expect(() => flowchart.addElement2(element3, "1.0.1.1.1"), returnsNormally);
    flowchart.addElement2(element4, "1");
    flowchart.removeElement2("2.0.1");

    expect(flowchart.elements2.length, 4);
    expect((flowchart.elements2["1"]!.nextElement), flowchart.elements2["2"]);
    expect(flowchart.elements2["2"]! is BranchingElement, true);
  });

   */
}