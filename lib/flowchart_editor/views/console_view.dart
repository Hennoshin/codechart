import 'package:code_chart/flowchart_editor/view_models/flowchart_editor_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/console_viewmodel.dart';

class ConsoleView extends StatelessWidget {
  final TextEditingController _inputController = TextEditingController();

  ConsoleView({super.key});

  void _inputToConsole(BuildContext context) {
    context.read<FlowchartEditorViewModel>().setInputBuffer(_inputController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1000,
      width: 500,
      child: Consumer<ConsoleViewModel>(
        builder: (_, consoleViewModel, __) =>
            Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                      itemCount: consoleViewModel.outputBuffer.length,
                      itemBuilder: (context, index) => Container(
                        height: 500,
                        width: 450,
                        child: Text(consoleViewModel.outputBuffer[index]),
                      )
                  )
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 450,
                      child: TextField(controller: _inputController)
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Colors.blue,
                      onPressed: consoleViewModel.expectingInput ? () {
                        _inputToConsole(context);
                      } : null,
                    )
                  ],
                )
              ],
            )
      ),
    );
  }

}