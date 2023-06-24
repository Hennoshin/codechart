import 'package:code_chart/flowchart_editor/models/flowchart_program.dart';
import 'package:code_chart/flowchart_editor/screens/basic_screen.dart';
import 'package:code_chart/flowchart_editor/view_models/function_manager_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../views/function_manager_view.dart';

class FunctionManagerScreen extends BasicScreen {
  const FunctionManagerScreen({super.key, required super.settings});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => FunctionManagerViewModel(settings.arguments as FlowchartProgram), child: const FunctionManagerView());
  }

}