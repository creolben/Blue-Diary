
import 'package:flutter/material.dart';

class ViewLayoutInfo {
  static ViewLayoutInfo create(Size size, Offset position) {
    return ViewLayoutInfo(
      left: position.dx,
      top: position.dy,
      width: size.width,
      height: size.height,
    );
  }

  final double left;
  final double top;
  final double width;
  final double height;

  const ViewLayoutInfo({
    @required this.left,
    @required this.top,
    @required this.width,
    @required this.height,
  });
}