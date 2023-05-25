import 'package:code_chart/flowchart_editor/view_models/console_viewmodel.dart';
import 'package:code_chart/flowchart_editor/view_models/flowchart_editor_viewmodel.dart';
import 'package:code_chart/flowchart_editor/view_models/flowchart_viewmodel.dart';
import 'package:code_chart/flowchart_editor/view_models/memory_viewmodel.dart';
import 'package:code_chart/flowchart_editor/views/flowchart_view.dart';
import 'package:code_chart/flowchart_editor/views/memory_view.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import 'console_view.dart';

class FlowchartEditorView extends StatefulWidget {

  const FlowchartEditorView({super.key});

  @override
  State<StatefulWidget> createState() => _FlowchartEditorViewState();

}

class _FlowchartEditorViewState extends State<FlowchartEditorView> {
  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<FlowchartEditorViewModel>();
    var programName = viewModel.programName;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(programName),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.one_k)),
              Tab(icon: Icon(Icons.one_k)),
              Tab(icon: Icon(Icons.one_k))
            ],
          ),
        ),
        body: Center(
          child: Container(
              padding: const EdgeInsets.all(10.0),
              child: TabBarView(
                children: <Widget>[
                  ChangeNotifierProxyProvider<FlowchartEditorViewModel, FlowchartViewModel>(
                    create: (_) => FlowchartViewModel(viewModel.currentFlowchart),
                    update: (_, flowchartEditorViewModel, fvm) => fvm!..update(flowchartEditorViewModel),
                    child: const FlowchartView(),
                  ),
                  ChangeNotifierProxyProvider<FlowchartEditorViewModel, MemoryViewModel>(
                    create: (_) => MemoryViewModel(),
                    update: (_, flowchartEditorViewModel, memoryVm) => memoryVm!..update(flowchartEditorViewModel),
                    child: const MemoryView(),
                  ),
                  ChangeNotifierProxyProvider<FlowchartEditorViewModel, ConsoleViewModel>(
                    create: (_) => ConsoleViewModel(),
                    update: (_, flowchartEditorViewModel, consoleVm) => consoleVm!..update(flowchartEditorViewModel),
                    child: const ConsoleView(),
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
                ElevatedButton(
                    onPressed: () {
                      context.read<FlowchartEditorViewModel>().addElement(0);
                    },
                    child: const Text("Element 1")),
                ElevatedButton(
                    onPressed: () {
                      context.read<FlowchartEditorViewModel>().addElement(1);
                    },
                    child: const Text("Element 2")),
                ElevatedButton(
                    onPressed: () {
                      context.read<FlowchartEditorViewModel>().addElement(2);
                    },
                    child: const Text("Element 3")),
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
              context.read<FlowchartEditorViewModel>().stepRunFlowchart();
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

/*

class _FlowchartModelView extends StatelessWidget {
  _FlowchartModelView({Key? key}) : super(key: key);

  Widget _createFlowchart(BaseElement startElement, [String current = "", bool isBranch = false, MergingElement? endPoint]) {
    print("Test build");
    BaseElement element = startElement;
    List<Widget> widgets = [];

    int i = 0;
    if (isBranch) {
      i += 1;

      widgets.add(_AddButton(index: current + i.toString()));
    }

    while (element.nextElement != element && element != endPoint) {
      if (element is BranchingElement) {
        widgets.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _createFlowchart(element.trueBranchNextElement, "$current$i.0.", true, element.mergePoint),
            ElementWidget(element: element, index: current + i.toString()),
            _createFlowchart(element.falseBranchNextElement, "$current$i.1.", true, element.mergePoint)
          ]
        ));
      }
      else {
        print(i);
        var c = ElementViewModel(element, current + i.toString());
        widgets.add(ElementWidget(element: element, index: current + i.toString()));
      }

      i += 1;
      widgets.add(_AddButton(index: current + i.toString()));

      element = element.nextElement;
    }

    if (!isBranch) {
      widgets.add(ElementWidget(element: element, index: current + i.toString()));
    }

    return Column(
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    Flowchart flowchart = context.watch<FlowchartEditorViewModel>().currentFlowchart;

    return _createFlowchart(flowchart.startElement);
  }
}

class _AddButton extends StatelessWidget {
  final String index;

  const _AddButton({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          context.read<FlowchartEditorViewModel>().setAddElementSelect(index);
        },
        child: Text(index)
    );
  }

}

 */