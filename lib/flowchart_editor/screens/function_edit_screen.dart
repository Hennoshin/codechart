import 'package:code_chart/flowchart_editor/models/flowchart_program.dart';
import 'package:code_chart/flowchart_editor/models/function_flowchart.dart';
import 'package:code_chart/commons/basic_screen.dart';
import 'package:code_chart/flowchart_editor/view_models/function_edit_viewmodel.dart';
import 'package:code_chart/flowchart_editor/view_models/function_manager_viewmodel.dart';
import 'package:code_chart/flowchart_editor/views/function_edit_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FunctionEditScreen extends BasicScreen {
  const FunctionEditScreen({super.key, required super.settings});

  @override
  Widget build(BuildContext context) {
    List args = settings.arguments as List;
    FunctionManagerViewModel vm = args.first as FunctionManagerViewModel;
    FunctionFlowchart? function = args.length == 2 ? args.last : null;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FunctionEditViewModel(function)),
        ChangeNotifierProvider.value(value: vm)
      ],
      child: const FunctionEditView(),
    );
  }
}