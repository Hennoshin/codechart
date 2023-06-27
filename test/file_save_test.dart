import 'dart:convert';
import 'dart:typed_data';

import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/models/declaration_element.dart';
import 'package:code_chart/utility/flowchart_program_save_file.dart';
import 'package:test/test.dart';
import 'package:code_chart/flowchart_editor/models/flowchart_program.dart';

void main() {
  late FlowchartProgram program;

  setUp(() {
    program = FlowchartProgram("Test Program");
  });

  test("Test save file output correctness", () {
    FlowchartProgramSaveFile saveFile = FlowchartProgramSaveFile(program);
    var elementsMap = program.mainFlowchart.elements2;

    Uint8List elementBytes = Uint8List.fromList(utf8.encode(jsonEncode({
      "elements": [
        {"index": "0", "element": elementsMap["0"]},
        {"index": "1", "element": elementsMap["1"]}
      ]
    })));

    expect(saveFile.buffer, Uint8List.fromList([
      67, 67, 86, 0,
      0, 0, 0, 0,
      32, 0, 0, 0, 0, 0, 0, 0 ] +
        saveFile.hashDigest.bytes +
        elementBytes
    ));
  });
}