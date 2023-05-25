import 'package:code_chart/flowchart_editor/models/output_element.dart';
import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/execution_environment/execution_environment.dart';
import 'package:code_chart/flowchart_editor/models/assignment_element.dart';
import 'package:code_chart/flowchart_editor/models/declaration_element.dart';
import 'package:code_chart/flowchart_editor/models/flowchart.dart';
import 'package:test/test.dart';

void main() {
  late Flowchart flowchart;
  late ExecutionEnvironment executionEnvironment;

  setUp(() {
    flowchart = Flowchart("main");
    executionEnvironment = ExecutionEnvironment(flowchart.startElement, {});
  });

  test("Test run console output 1", () {
    flowchart.addElement2(OutputElement("\"Hello World\""), "1");

    while (executionEnvironment.stepRunElement()) {}

    expect(executionEnvironment.outputBuffer[0], "Hello World");
  });

  test("Test run console output 2", () {
    flowchart.addElement2(DeclarationElement("num", false, DataType.integer), "1");
    flowchart.addElement2(AssignmentElement("5", "num"), "2");
    flowchart.addElement2(OutputElement("num + 7"), "3");

    while (executionEnvironment.stepRunElement()) {}

    expect(executionEnvironment.outputBuffer[0], "12");
  });
}