import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
    this.isLabelToTheRight = false,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;
  final bool isLabelToTheRight;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
    final indicator = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
        color: color,
      ),
    );
    return Row(
      children: <Widget>[
        isLabelToTheRight ? label : indicator,
        const SizedBox(
          width: 4,
        ),
        isLabelToTheRight ? indicator : label,
      ],
    );
  }
}
