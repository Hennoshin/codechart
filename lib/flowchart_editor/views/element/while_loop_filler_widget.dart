import 'package:flutter/material.dart';

class WhileLoopFillerWidget extends StatelessWidget {
  const WhileLoopFillerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(100, double.infinity),
      painter: _WhileLoopFillerWidget(),
    );
  }

}

class _WhileLoopFillerWidget extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.black;

    canvas.drawRect(Rect.fromLTRB(size.width / 2 - 5, 0, size.width / 2 + 5, size.height), paint);

    List<Offset> points = [
      Offset(0, size.height - 30),
      Offset(10, size.height - 30),
      Offset(10, 10),
      Offset(5, 10),
      Offset(15, 0),
      Offset(25, 10),
      Offset(20, 10),
      Offset(20, size.height - 20),
      Offset(0, size.height - 20)
    ];

    Path path = Path();
    path.addPolygon(points, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}