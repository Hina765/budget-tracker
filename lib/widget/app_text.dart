import 'package:flutter/material.dart';

class AppText extends StatelessWidget {

  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  const AppText(
    this.text,
    this.fontSize,
    this.color,
    this.fontWeight,
    {super.key}
  );

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: "Sen",
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight
      ),
    );
  }
}
