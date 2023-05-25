import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/models/declaration_element.dart';
import 'package:flutter/material.dart';

class DeclarationElementEditView extends StatefulWidget {
  final DeclarationElement _element;

  const DeclarationElementEditView({super.key, required element}) : _element = element;

  @override
  State<StatefulWidget> createState() => _DeclarationElementEditViewState();
}

class _DeclarationElementEditViewState extends State<DeclarationElementEditView> {
  late DataType _dataType;
  late bool _isArray;
  late int? _arraySize;

  late final TextEditingController _varNameController;

  @override
  void initState() {
    super.initState();

    _dataType = widget._element.varType;
    _isArray = widget._element.isArray;
    _arraySize = widget._element.arraySize;

    _varNameController = TextEditingController(text: widget._element.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Declaration Element"),
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
            properties.add(_varNameController.text);
            properties.add(_dataType);
            properties.add(_isArray);
            properties.add(_arraySize);

            Navigator.pop(context, properties);
          },
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _varNameController,
          ),
          DropdownButton<DataType>(
            value: _dataType,
            items: DataType.values.map<DropdownMenuItem<DataType>>((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(e.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _dataType = value!;
              });
            },
          ),
        ],
      )
    );
  }
  
}