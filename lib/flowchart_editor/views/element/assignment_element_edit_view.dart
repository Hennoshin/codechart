import 'package:code_chart/flowchart_editor/models/assignment_element.dart';
import 'package:flutter/material.dart';

class AssignmentElementEditView extends StatefulWidget {
  final AssignmentElement _element;

  const AssignmentElementEditView({super.key, required element}) : _element = element;

  @override
  State<StatefulWidget> createState() => _AssignmentElementEditViewState();
}

class _AssignmentElementEditViewState extends State<AssignmentElementEditView> {
  late final TextEditingController _leftOpController;
  late final TextEditingController _rightOpController;

  @override
  void initState() {
    super.initState();

    var element = widget._element;
    _leftOpController = TextEditingController(text: element.assignmentExpr);
    _rightOpController = TextEditingController(text: element.baseExpr);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("Edit Assignment Element"),
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
              properties.add(_rightOpController.text);

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
            TextField(
              controller: _rightOpController,
            )
          ],
        )
    );
  }

}