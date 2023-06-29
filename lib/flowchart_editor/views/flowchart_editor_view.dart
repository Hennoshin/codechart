import 'dart:convert';

import 'package:code_chart/commons/error_dialog.dart';
import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/models/assignment_element.dart';
import 'package:code_chart/flowchart_editor/models/branching_element.dart';
import 'package:code_chart/flowchart_editor/models/declaration_element.dart';
import 'package:code_chart/flowchart_editor/models/function_call_element.dart';
import 'package:code_chart/flowchart_editor/models/input_element.dart';
import 'package:code_chart/flowchart_editor/models/output_element.dart';
import 'package:code_chart/flowchart_editor/models/while_loop_element.dart';
import 'package:code_chart/flowchart_editor/view_models/console_viewmodel.dart';
import 'package:code_chart/flowchart_editor/view_models/flowchart_editor_viewmodel.dart';
import 'package:code_chart/flowchart_editor/view_models/flowchart_viewmodel.dart';
import 'package:code_chart/flowchart_editor/view_models/memory_viewmodel.dart';
import 'package:code_chart/flowchart_editor/views/flowchart_view.dart';
import 'package:code_chart/flowchart_editor/views/memory_view.dart';
import 'package:code_chart/utility/file_io_service.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import '../../commons/routes.dart';
import '../models/base_element.dart';
import 'console_view.dart';

class FlowchartEditorView extends StatefulWidget {

  const FlowchartEditorView({super.key});

  @override
  State<StatefulWidget> createState() => _FlowchartEditorViewState();

}

class _FlowchartEditorViewState extends State<FlowchartEditorView> {
  final ScrollController _controller = ScrollController();
  final GlobalKey _flowchartViewKey = GlobalKey();

  Future<void> generateFlowchartImage(BuildContext context) async {
    FlowchartEditorViewModel vm = context.read<FlowchartEditorViewModel>();
    try {
      var imageData = await (_flowchartViewKey.currentWidget! as FlowchartView).captureFlowchart();
      if (imageData == null) {
        throw Exception("Unable to create image. Unknown error");
      }

      print(base64.encode(imageData));

      FileIOService service = FileIOService.instance;
      await service.saveToFile(fileName: "${vm.programName} ${vm.currentFlowchartID}.png", bytes: imageData, mime: "image/png");
    }
    catch (e) {
      showDialog(context: context, builder: (_) => ErrorDialog(title: "Failed to generate flowchart image", content: e.toString()));
    }
  }

  BaseElement _createElement(BaseElement element) {
    element.nextElement = element;
    
    return element;
  }
  
  Widget _buildAddElementWidget({required BaseElement element, required String name}) {
    return LongPressDraggable<BaseElement>(
      data: element,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: SizedBox(
        child: Text(name),
      ),
      child: SizedBox(
        child: Container(
          margin: const EdgeInsetsDirectional.only(start: 10, end: 10),
          padding: const EdgeInsetsDirectional.all(5),
          color: Colors.blue,
          child: Text(name)
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<FlowchartEditorViewModel>();
    var programName = viewModel.programName;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(programName),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                String? newName = await showDialog(context: context, builder: (_) => _EditProgramNameDialog(currentName: programName));

                if (newName == null) {
                  return;
                }

                viewModel.setProgramName(newName);
              },
            ),
            IconButton(
              icon: const Icon(Icons.download_sharp),
              onPressed: () async {
                try {
                  await viewModel.loadProgram();
                }
                catch (e) {
                  showDialog(context: context, builder: (_) => ErrorDialog(title: "Failed to load file", content: e.toString()));
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                await viewModel.saveProgram();
              },
            ),
            IconButton(
              icon: const Icon(Icons.download_sharp),
              onPressed: () {
                generateFlowchartImage(context);
              },
            ),
            DropdownButton<String>(
              value: viewModel.currentFlowchartID,
              items: <DropdownMenuItem<String>>[
                const DropdownMenuItem(
                  value: "main",
                  child: Text("Main"),
                ),
                for (var str in viewModel.mainProgram.functionTable.keys)
                  DropdownMenuItem(
                    value: str,
                    child: Text(str),
                  ),
              ],
              onChanged: (value) {
                viewModel.setCurrentFlowchart(value!);
              },
            ),
            IconButton(
              icon: const Icon(Icons.functions),
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.functionManager, arguments: viewModel.mainProgram);
              },
            )
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.account_tree)),
              Tab(icon: Icon(Icons.memory)),
              Tab(icon: Icon(Icons.wysiwyg))
            ],
          ),
        ),
        body: Center(
          child: Container(
              padding: const EdgeInsets.all(10.0),
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  ChangeNotifierProxyProvider<FlowchartEditorViewModel, FlowchartViewModel>(
                    create: (_) => FlowchartViewModel(viewModel.currentFlowchart),
                    update: (_, flowchartEditorViewModel, fvm) => fvm!..update(flowchartEditorViewModel),
                    child: Center(
                      child: FlowchartView(key: _flowchartViewKey),
                    ),
                  ),
                  ChangeNotifierProxyProvider<FlowchartEditorViewModel, MemoryViewModel>(
                    create: (_) => MemoryViewModel(),
                    update: (_, flowchartEditorViewModel, memoryVm) => memoryVm!..update(flowchartEditorViewModel),
                    child: const MemoryView(),
                  ),
                  ChangeNotifierProxyProvider<FlowchartEditorViewModel, ConsoleViewModel>(
                    create: (_) => ConsoleViewModel(),
                    update: (_, flowchartEditorViewModel, consoleVm) => consoleVm!..update(flowchartEditorViewModel),
                    child: ConsoleView(),
                  )
                ],
              )
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: <Widget>[
                const _FlowchartExecutionControl(),
                Expanded(
                  child: Container(
                    height: 40,
                    child: ListView(
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        _buildAddElementWidget(element: _createElement(DeclarationElement(null, false, DataType.integer)), name: "Declaration Element"),
                        _buildAddElementWidget(element: _createElement(AssignmentElement(null, null)), name: "Assignment Element"),
                        _buildAddElementWidget(element: _createElement(InputElement(null)), name: "Input Element"),
                        _buildAddElementWidget(element: _createElement(OutputElement(null)), name: "Output Element"),
                        _buildAddElementWidget(element: _createElement(FunctionCallElement(null)), name: "Function Call Element"),
                        _buildAddElementWidget(element: _createElement(BranchingElement(null)), name: "Branching Element"),
                        _buildAddElementWidget(element: _createElement(WhileLoopElement(null)), name: "While-Loop Element"),
                      ],
                    ),
                  )
                ),
                const _ToolsRow()
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class _ToolsRow extends StatelessWidget {
  const _ToolsRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<FlowchartEditorViewModel, Set<int>>(
      selector: (_, vm) => { vm.selectedToolsIndex },
      builder: (context, selectedIndex, _) {
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.delete),
              color: selectedIndex.single == 0 ? Colors.red : Colors.grey,
              onPressed: () {
                context.read<FlowchartEditorViewModel>().selectedToolsIndex = 0;
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              color: selectedIndex.single == 1 ? Colors.blue : Colors.grey,
              onPressed: () {
                context.read<FlowchartEditorViewModel>().selectedToolsIndex = 1;
              },
            )
          ],
        );
      }
    );
  }
}

class _FlowchartExecutionControl extends StatelessWidget {
  const _FlowchartExecutionControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<FlowchartEditorViewModel, bool>(
      selector: (_, vm) => vm.isFlowchartRunning,
      builder: (_, isRunning, __) => Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.play_arrow),
            color: Colors.green,
            onPressed: () {
              try {
                context.read<FlowchartEditorViewModel>().stepRunFlowchart();
              }
              catch (e) {
                showDialog(context: context, builder: (_) => ErrorDialog(title: "Execution Error", content: e.toString()));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            color: isRunning ? Colors.red : null,
            onPressed: isRunning ? () {
              context.read<FlowchartEditorViewModel>().stopFlowchart();
            } : null,
          )
        ],
      ),
    );
  }
}

class _EditProgramNameDialog extends StatefulWidget {
  final String currentName;

  const _EditProgramNameDialog({super.key, required this.currentName});

  @override
  State<StatefulWidget> createState() => _EditProgramNameDialogState();

}

class _EditProgramNameDialogState extends State<_EditProgramNameDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _controller.text = widget.currentName;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Program Name"),
      content: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          label: const Text("Name"),
          errorText: _errorMessage
        ),
      ),
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
            if (_controller.text == "") {
              setState(() {
                _errorMessage = "Name cannot be empty";
              });

              return;
            }

            Navigator.pop(context, _controller.text);
          },
        )
      ],
    );
  }

}