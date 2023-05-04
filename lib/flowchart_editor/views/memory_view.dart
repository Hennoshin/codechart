import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/execution_environment/memory.dart';
import 'package:code_chart/flowchart_editor/view_models/execution_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemoryView extends StatelessWidget {
  const MemoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ExecutionViewModel? vm = context.watch<ExecutionViewModel?>();
    List<Widget> widgets = [const SizedBox(
      height: 50,
      child: Center(child: Text("Empty"))
    )];
    if (vm != null) {
      widgets.clear();

      Memory memory = vm.environment!.topStack;
      for (MapEntry<String, Wrapper> item in memory.variables.entries) {
        String varName = item.key;
        dynamic value = item.value.value ?? "Uninitialized";

        widgets.add(SizedBox(
            height: 50,
            child: Center(child: Text("$varName = $value"))
        ));
      }
    }

    return ListView(
      children: widgets,
    );
  }

}