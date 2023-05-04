import 'package:code_chart/flowchart_editor/models/flowchart_program.dart';
import 'package:code_chart/flowchart_editor/view_models/flowchart_editor_viewmodel.dart';
import 'package:code_chart/flowchart_editor/views/flowchart_editor_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FlowchartEditorScreen extends StatelessWidget {
  final FlowchartProgram flowchart = FlowchartProgram("Untitled");

  FlowchartEditorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => FlowchartEditorViewModel(flowchart), child: const FlowchartEditorView(),);
  }

}