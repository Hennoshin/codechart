import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:tuple/tuple.dart";

import "../../view_models/flowchart_editor_viewmodel.dart";
import "../../view_models/flowchart_viewmodel.dart";
import '../../models/base_element.dart';
import "element_edit_view_factory.dart";

class FunctionCallElementWidget extends StatelessWidget {
  final String positionIndex;

  const FunctionCallElementWidget({super.key, required this.positionIndex});

  // TODO: This part is basically boiler-plate, merge it into a single object
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
          builder: (_, data, __) => CustomPaint(
            painter: _FunctionCallElementPainter(color: data.item2 ? Colors.green : Colors.blue),
            size: const Size(100, 50),
            child: Text(data.item1),
          )
      ),
    );
  }

}

class _FunctionCallElementPainter extends CustomPainter {
  final Color color;

  _FunctionCallElementPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();

    List<Offset> points = [
      Offset(0, size.height),
      Offset(20, 0),
      Offset(size.width, 0),
      Offset(size.width - 20, size.height)
    ];

    path.addPolygon(points, true);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _FunctionCallElementPainter oldDelegate) {
    return oldDelegate.color != color;
  }

}