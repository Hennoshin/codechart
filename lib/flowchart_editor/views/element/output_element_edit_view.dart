import 'package:code_chart/flowchart_editor/models/output_element.dart';
import 'package:flutter/material.dart';

class OutputElementEditView extends StatefulWidget {
  final OutputElement _element;

  const OutputElementEditView({super.key, required element}) : _element = element;

  @override
  State<StatefulWidget> createState() => _OutputElementEditViewState();
}

class _OutputElementEditViewState extends State<OutputElementEditView> {
  late final TextEditingController _leftOpController;

  @override
  void initState() {
    super.initState();

    _leftOpController = TextEditingController(text: widget._element.baseExpr);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("Edit Output Element"),
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