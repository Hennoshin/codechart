import 'package:code_chart/code_converter/model/converted_codes.dart';
import 'package:code_chart/flowchart_editor/models/flowchart.dart';
import 'package:code_chart/flowchart_editor/models/flowchart_program.dart';
import 'package:flutter/foundation.dart';

class CodeConversionViewModel extends ChangeNotifier {
  final ConvertedCodes codes;

  CodeConversionViewModel(FlowchartProgram program) : codes = ConvertedCodes(program);


}