import "dart:math";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:tuple/tuple.dart";

import "../../view_models/flowchart_editor_viewmodel.dart";
import "../../view_models/flowchart_viewmodel.dart";
import '../../models/base_element.dart';
import "element_edit_view_factory.dart";

class TerminalElementWidget extends StatelessWidget {
  final String positionIndex;

  const TerminalElementWidget({super.key, required this.positionIndex});

  // TODO: This part is basically boiler-plate, merge it into a single object

  @override
  Widget build(BuildContext context) {
    return Selector2<FlowchartViewModel, FlowchartEditorViewModel, Tuple2<String, bool>>(
        selector: (_, vm1, vm2) {
          BaseElement? element = vm1.elementAt(positionIndex);
          return Tuple2(element.toString(), element == vm2.currentRunElement());
        },
        builder: (_, data, __) => CustomPaint(
          painter: _TerminalElementPainter(color: data.item2 ? Colors.green : Colors.blue),
          size: const Size(100, 50),
          child: Text(data.item1),
        )
    );
  }

}

class _TerminalElementPainter extends CustomPainter {
  final Color color;

  _TerminalElementPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color;

    canvas.drawArc(Rect.fromLTRB(0, 0, size.width / 2, size.height), pi / 2, pi, true, paint);
    canvas.drawRect(Rect.fromLTRB(size.width / 4 - 1, 0, size.width * 3 / 4 + 1, size.height), paint);
    canvas.drawArc(Rect.fromLTRB(size.width / 2, 0, size.width, size.height), 3 * pi / 2, pi, true, paint);
  }

  @override
  bool shouldRepaint(covariant _TerminalElementPainter oldDelegate) {
    return oldDelegate.color != color;
  }

}