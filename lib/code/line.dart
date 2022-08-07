import 'package:flutter/material.dart';

/// This line is used to draw a line between profile picture and username
class StrikeThroughDecoration extends Decoration {
  final Color color;
  StrikeThroughDecoration({this.color});
  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return new _StrikeThroughPainter(color: color);
  }
}

class _StrikeThroughPainter extends BoxPainter {
  final Color color;
  _StrikeThroughPainter({this.color});
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = new Paint()
      ..strokeWidth = 1.0
      ..color = color != null ? color : Colors.grey[300]
      ..style = PaintingStyle.fill;

    final rect = offset & configuration.size;
    canvas.drawLine(new Offset(rect.left, rect.bottom + 20),
        new Offset(rect.right, rect.bottom + 20), paint);
    canvas.restore();
  }
}
