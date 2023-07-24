import "package:flutter/material.dart";

class MergeElementWidget extends StatelessWidget {

  const MergeElementWidget({super.key});

  // TODO: This part is basically boiler-plate, merge it into a single object
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: _AssignmentElementPainter(),
        size: const Size(100, 50)
    );
  }

}

class _AssignmentElementPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTRB(0, size.height / 2 - 5, size.width, size.height / 2 + 5), Paint());
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.height / 2, Paint()..color = Colors.green);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}