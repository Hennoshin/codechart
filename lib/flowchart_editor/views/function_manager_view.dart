import 'package:code_chart/commons/routes.dart';
import 'package:code_chart/flowchart_editor/view_models/function_manager_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/function_flowchart.dart';

class FunctionManagerView extends StatelessWidget {
  const FunctionManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    FunctionManagerViewModel viewModel = context.watch<FunctionManagerViewModel>();
    Map<String, FunctionFlowchart> functions = viewModel.flowchartProgram.functionTable;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Function Manager"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.pushNamed(context, RouteNames.functionEdit, arguments: [viewModel]);
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: functions.length,
        itemBuilder: (context, index) => _createFunctionEntry(context, functions, index)
      )
    );
  }

  Widget _createFunctionEntry(BuildContext context, Map<String, FunctionFlowchart> functions, int index) {
    FunctionFlowchart functionFlowchart = functions[functions.keys.elementAt(index)]!;

    return ListTile(
      title: Text(functionFlowchart.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            color: Colors.blue,
            onPressed: () {
              var vm = context.read<FunctionManagerViewModel>();
              Navigator.pushNamed(context, RouteNames.functionEdit, arguments: [vm, functionFlowchart]);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: () {
              context.read<FunctionManagerViewModel>().deleteFunction(functions.keys.elementAt(index));
            },
          )
        ],
      )
    );
  }
  
}