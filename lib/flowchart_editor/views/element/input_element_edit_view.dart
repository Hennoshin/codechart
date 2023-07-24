import 'package:code_chart/flowchart_editor/models/input_element.dart';
import 'package:flutter/material.dart';

class InputElementEditView extends StatefulWidget {
  final InputElement _element;

  const InputElementEditView({super.key, required element}) : _element = element;

  @override
  State<StatefulWidget> createState() => _InputElementEditViewState();
}

class _InputElementEditViewState extends State<InputElementEditView> {
  late final TextEditingController _inputVarController;
  late final TextEditingController _promptController;

  @override
  void initState() {
    super.initState();

    _inputVarController = TextEditingController(text: widget._element.baseExpr);
    _promptController = TextEditingController(text: widget._element.prompt);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("Edit Input Element"),
        actions: <Widget>[
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text("Save"),
            onPressed: () {
              List<dynamic> properties = [];
              properties.add(_inputVarController.text);
              properties.add(_promptController.text);

              Navigator.pop(context, properties);
            },
          ),
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _inputVarController,
            ),
            TextField(
              controller: _promptController,
            )
          ],
        )
    );
  }

}