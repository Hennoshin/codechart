import 'package:code_chart/flowchart_editor/models/function_call_element.dart';
import 'package:code_chart/flowchart_editor/models/output_element.dart';
import 'package:flutter/material.dart';

class FunctionCallElementEditView extends StatefulWidget {
  final FunctionCallElement _element;

  const FunctionCallElementEditView({super.key, required element}) : _element = element;

  @override
  State<StatefulWidget> createState() => _FunctionCallElementEditViewState();
}

class _FunctionCallElementEditViewState extends State<FunctionCallElementEditView> {
  late final TextEditingController _leftOpController;

  @override
  void initState() {
    super.initState();

    _leftOpController = TextEditingController(text: widget._element.baseExpr);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("Edit Function Call Element"),
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
              properties.add(_leftOpController.text);

              Navigator.pop(context, properties);
            },
          ),
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _leftOpController,
            ),
          ],
        )
    );
  }

}