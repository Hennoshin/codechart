import 'dart:convert';

import 'package:code_chart/code_converter/model/converted_codes.dart';
import 'package:code_chart/flowchart_editor/models/flowchart_program.dart';
import 'package:code_chart/utility/file_io_service.dart';
import 'package:flutter/foundation.dart';

class CodeConversionViewModel extends ChangeNotifier {
  final ConvertedCodes codes;

  CodeConversionViewModel(FlowchartProgram program) : codes = ConvertedCodes(program);

  Future<void> saveCode() async {
    FileIOService service = FileIOService.instance;

    await service.saveToFile(fileName: "${codes.program.programName}.cpp", bytes: Uint8List.fromList(utf8.encode(codes.toString())), mime: "text/plain");
  }

  String get rawCodes => codes.sourceCode.join("\n");
}