import 'package:code_chart/flowchart_editor/models/terminal_element.dart';
import 'package:code_chart/flowchart_editor/view_models/element_viewmodel.dart';
import 'package:code_chart/flowchart_editor/view_models/flowchart_viewmodel.dart';
import 'package:code_chart/flowchart_editor/views/element/element_edit_view_factory.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import '../../models/base_element.dart';
import '../../view_models/flowchart_editor_viewmodel.dart';


class ElementWidget extends StatelessWidget {
  final String positionIndex;

  const ElementWidget({super.key, required this.positionIndex});

  void _deleteCurrentElement(BuildContext context) {
    context.read<FlowchartViewModel>().removeElement(positionIndex);
  }

  void _editCurrentElement(BuildContext context) async {
    BaseElement element = context.read<FlowchartViewModel>().elementAt(positionIndex)!;
    Widget? dialog = const ElementEditViewFactory().createElementEditView(element);

    List<dynamic>? properties = dialog != null ? await showDialog<List<dynamic>>(
        context: context,
        builder: (_) => dialog
    ) : null;

    if (properties == null || !context.mounted) {
      return;
    }

    context.read<FlowchartViewModel>().updateElementAt(positionIndex, properties);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        int selectedTool = context.read<FlowchartEditorViewModel>().selectedToolsIndex;

        if (selectedTool == 0) {
          _deleteCurrentElement(context);
        }
        else if (selectedTool == 1) {
          _editCurrentElement(context);
        }
      },
      child: Selector2<FlowchartViewModel, FlowchartEditorViewModel, Tuple2<String, bool>>(
        selector: (_, vm1, vm2) {
          BaseElement? element = vm1.elementAt(positionIndex);
          return Tuple2(element.toString(), element == vm2.currentRunElement());
        },
        builder: (_, data, __) => Container(
          color: data.item2 ? Colors.green : Colors.red,
          width: 100,
          height: 50,
          child: Text(data.item1),
        ),
      ),
    );
  }

}