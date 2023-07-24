import 'package:code_chart/code_converter/view_models/code_conversion_viewmodel.dart';
import 'package:code_chart/code_converter/views/code_conversion_view.dart';
import 'package:code_chart/commons/basic_screen.dart';
import 'package:code_chart/flowchart_editor/models/flowchart_program.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

class CodeConversionScreen extends BasicScreen {
  const CodeConversionScreen({super.key, required super.settings});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CodeConversionViewModel(settings.arguments! as FlowchartProgram),
      child: const CodeConversionView(),
    );
  }

}