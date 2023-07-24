import 'package:flutter/material.dart';

import '../../models/branching_element.dart';

class BranchingElementEditView extends StatefulWidget {
  final BranchingElement _element;

  const BranchingElementEditView({super.key, required element}) : _element = element;

  @override
  State<StatefulWidget> createState() => _BranchingElementEditViewState();
}

class _BranchingElementEditViewState extends State<BranchingElementEditView> {
  late final TextEditingController _leftOpController;

  @override
  void initState() {
    super.initState();

    _leftOpController = TextEditingController(text: widget._element.baseExpr);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("Edit Branch Element"),
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