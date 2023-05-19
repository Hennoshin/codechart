import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/flowchart_editor/models/flowchart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/branching_element.dart';
import '../models/merging_element.dart';
import '../view_models/flowchart_editor_viewmodel.dart';
import '../view_models/flowchart_viewmodel.dart';
import 'element/element_widget.dart';

class FlowchartView extends StatelessWidget {
  const FlowchartView({Key? key}) : super(key: key);

  // TODO: Change it so that it does not rely on recursive, each element is mapped now, figure something out?
  Widget _createFlowchartColumn(BaseElement startElement, [String current = "", bool isBranch = false, MergingElement? endPoint]) {
    BaseElement element = startElement;
    List<Widget> widgets = [];

    int i = 0;
    if (isBranch) {
      i += 1;

      widgets.add(_AddButton(position: current + i.toString()));
    }

    while (element.nextElement != element && element != endPoint) {
      if (element is BranchingElement) {
        widgets.add(Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _createFlowchartColumn(element.trueBranchNextElement, "$current$i.0.", true, element.mergePoint),
              ElementWidget2(positionIndex: current + i.toString()),
              _createFlowchartColumn(element.falseBranchNextElement, "$current$i.1.", true, element.mergePoint)
            ]
        ));
      }
      else {
        widgets.add(ElementWidget2(positionIndex: current + i.toString()));
      }

      i += 1;
      widgets.add(_AddButton(position: current + i.toString()));

      element = element.nextElement;
    }

    if (!isBranch) {
      widgets.add(ElementWidget2(positionIndex: current + i.toString()));
    }

    return Column(
      children: widgets,
    );

  }

  @override
  Widget build(BuildContext context) {
    Flowchart flowchart = context.watch<FlowchartViewModel>().flowchart;
    BaseElement startElement = flowchart.startElement;

    return _createFlowchartColumn(startElement);
  }

}

class _AddButton extends StatelessWidget {
  final String position;

  const _AddButton({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(position),
      onPressed: () {
        context.read<FlowchartEditorViewModel>().setAddElementSelect(position);
      },
    );
  }

}