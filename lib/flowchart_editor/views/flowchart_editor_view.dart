import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/flowchart_editor/models/branching_element.dart';
import 'package:code_chart/flowchart_editor/models/flowchart.dart';
import 'package:code_chart/flowchart_editor/models/merging_element.dart';
import 'package:code_chart/flowchart_editor/view_models/element_viewmodel.dart';
import 'package:code_chart/flowchart_editor/view_models/flowchart_editor_viewmodel.dart';
import 'package:code_chart/flowchart_editor/views/memory_view.dart';
import 'package:code_chart/flowchart_editor/widgets/element_widget.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(programName),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: _FlowchartModelView()
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: <Widget>[
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
    );
  }

}

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
            ChangeNotifierProvider(
              create: (_) => ElementViewModel(element, current + i.toString()),
              lazy: false,
              child: ElementWidget(element: element, index: current + i.toString()),
            ),
            _createFlowchart(element.falseBranchNextElement, "$current$i.1.", true, element.mergePoint)
          ]
        ));
      }
      else {
        print(i);
        var c = ElementViewModel(element, current + i.toString());
        widgets.add(ChangeNotifierProvider.value(
          value: c,
          child: ElementWidget(element: element, index: current + i.toString()),
        ));
      }

      i += 1;
      widgets.add(_AddButton(index: current + i.toString()));

      element = element.nextElement;
    }

    if (!isBranch) {
      widgets.add(ChangeNotifierProvider(
        create: (_) {
          print("Notifier builder ${current + i.toString()}");
          return ElementViewModel(element, current + i.toString());
        },
        lazy: false,
        child: ElementWidget(element: element, index: current + i.toString()),
      ));
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