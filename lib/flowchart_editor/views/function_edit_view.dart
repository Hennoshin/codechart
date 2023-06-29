import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/models/function_flowchart.dart';
import 'package:code_chart/flowchart_editor/view_models/function_edit_viewmodel.dart';
import 'package:code_chart/flowchart_editor/view_models/function_manager_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class FunctionEditView extends StatefulWidget {
  const FunctionEditView({super.key});

  @override
  State<StatefulWidget> createState() => _FunctionEditViewState();

}

class _FunctionEditViewState extends State<FunctionEditView> {
  final GlobalKey<FormFieldState<String>> _functionNameKey = GlobalKey();
  final GlobalKey<FormFieldState> _returnExpressionKey = GlobalKey();

  int? selectedParam;

  @override
  Widget build(BuildContext context) {
    FunctionEditViewModel viewModel = context.watch<FunctionEditViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }
        ),
        title: const Text("Edit Function Properties"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              var parentViewModel = context.read<FunctionManagerViewModel>();
              String fName = _functionNameKey.currentState!.value ?? "";
              String returnExpr = _returnExpressionKey.currentState!.value ?? "";

              if (viewModel.functionFlowchart == null) {
                parentViewModel.addNewFunction(fName, viewModel.returnType, returnExpr, viewModel.functionParameters);
              }
              else {
                parentViewModel.changeFunction(viewModel.functionFlowchart!.name, fName, viewModel.returnType, returnExpr, viewModel.functionParameters);
              }

              if (parentViewModel.hasError) {
                print(parentViewModel.lastError);

                return;
              }

              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white
            ),
            child: Text(viewModel.functionFlowchart == null ? "Add" : "Save"),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextFormField(
              key: _functionNameKey,
              initialValue: viewModel.functionFlowchart?.name,
              decoration: const InputDecoration(
                  labelText: "Function Name",
              ),
            ),
            DropdownButton<DataType?>(
              value: viewModel.returnType,
              items: [
                for (DataType type in DataType.values)
                  DropdownMenuItem<DataType>(
                    value: type,
                    child: Text(type.name),
                  ),
                const DropdownMenuItem(
                  value: null,
                  child: Text("void"),
                )
              ],
              onChanged: (type) {
                viewModel.returnType = type;
              },
            ),
            TextFormField(
              key: _returnExpressionKey,
              initialValue: viewModel.functionFlowchart?.returnExpression,
              enabled: viewModel.returnType != null,
              decoration: const InputDecoration(
                labelText: "Return Expression"
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                decoration: BoxDecoration(
                  border: Border.all()
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const ListTile(
                      title: Text("List of Parameters"),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: viewModel.functionParameters.length,
                        itemBuilder: (context, index) => Selector<FunctionEditViewModel, Tuple3<String, DataType, bool>>(
                          selector: (_, vm) {
                            var param = vm.functionParameters[index];

                            return Tuple3(param.name, param.type, param.isArray);
                          },
                          builder: (_, data, __) {
                            return ListTile(
                              selected: selectedParam == index,
                              title: Text("${data.item2.name} ${data.item1}"),
                              onTap: () {
                                setState(() {
                                  selectedParam = selectedParam != index ? index : null;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    )
                  ],
                )
              )
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ElevatedButton(
                  child: const Text("Add"),
                  onPressed: () async {
                    Future<List?> paramFuture = showDialog(
                        context: context,
                        builder: (_) => const _FunctionParamEditDialog()
                    );

                    List<dynamic>? result = await paramFuture;

                    if (result == null) return;

                    viewModel.addFunctionParam(result[0], result[1], result[2]);
                  },
                ),
                ElevatedButton(
                  onPressed: selectedParam != null ? () async {
                    Future<List?> paramFuture = showDialog(
                        context: context,
                        builder: (_) => _FunctionParamEditDialog(param: viewModel.functionParameters[selectedParam!])
                    );

                    List<dynamic>? result = await paramFuture;

                    if (result == null) return;

                    viewModel.editFunctionParam(selectedParam!, result[0], result[1], result[2]);
                  } : null,
                  child: const Text("Edit"),
                ),
                ElevatedButton(
                  onPressed: selectedParam != null ? () {
                    viewModel.deleteFunctionParam(selectedParam!);
                  } : null,
                  child: const Text("Delete"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _FunctionParamEditDialog extends StatefulWidget {
  final FunctionArg? param;

  const _FunctionParamEditDialog({super.key, this.param});

  @override
  State<StatefulWidget> createState() => _FunctionParamEditDialogState();

}

class _FunctionParamEditDialogState extends State<_FunctionParamEditDialog> {
  late DataType _type;
  String? _varNameError;
  final _formKey = GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();

    _type = widget.param?.type ?? DataType.integer;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Function Parameter"),
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
            if ((_formKey.currentState!.value ?? "") == "") {
              setState(() {
                _varNameError = "Variable name cannot be empty";
              });

              return;
            }

            Navigator.pop(context, <dynamic>[_formKey.currentState!.value, _type, false]);
          },
        )
      ],
      content: Column(
      mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            key: _formKey,
            initialValue: widget.param?.name,
            decoration: InputDecoration(
              errorText: _varNameError
            ),
          ),
          DropdownButton<DataType>(
            value: _type,
            items: [
              for (var type in DataType.values)
                DropdownMenuItem<DataType>(
                  value: type,
                  child: Text(type.name),
                )
            ],
            onChanged: (type) {
              setState(() {
                _type = type!;
              });
            },
          )
        ]
      ),
    );
  }

}