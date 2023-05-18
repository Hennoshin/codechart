import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/execution_environment/memory.dart';
import 'package:code_chart/flowchart_editor/view_models/execution_viewmodel.dart';
import 'package:code_chart/flowchart_editor/view_models/memory_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemoryView extends StatelessWidget {
  const MemoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<MemoryViewModel, List<Memory>>(
      selector: (_, vm) => vm.memory,
      builder: (_, list, __) => list.isEmpty ?
      const Text("Memory empty") :
      ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) => ExpansionTile(
          title: Text(list[index].stackName),
          children: <Widget>[
            ListView.builder(
              itemCount: list[index].variables.length,
              itemBuilder: (_, index) => _VariableEntry(
                  varName: list[index].variables.keys.elementAt(index),
                  stackIndex: index
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _VariableEntry extends StatelessWidget {
  final String varName;
  final int stackIndex;

  const _VariableEntry({super.key, required this.varName, required this.stackIndex});

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 200,
      decoration: BoxDecoration(
          border: Border.all()
      ),
      child: Column(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide()
                )
            ),
            child: Text(varName),
          ),
          Selector<MemoryViewModel, dynamic>(
            selector: (_, vm) => vm.memory[stackIndex].getData(varName).value,
            builder: (_, value, __) => Text(value.toString()),
          )
        ],
      ),
    );
  }
}