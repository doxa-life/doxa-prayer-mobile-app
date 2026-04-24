import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  const Gap._(this._size, {this.horizontal = false});

  static const xs = Gap._(4);
  static const s = Gap._(8);
  static const m = Gap._(16);
  static const l = Gap._(24);
  static const xl = Gap._(32);

  static const xsH = Gap._(4, horizontal: true);
  static const sH = Gap._(8, horizontal: true);
  static const mH = Gap._(16, horizontal: true);
  static const lH = Gap._(24, horizontal: true);
  static const xlH = Gap._(32, horizontal: true);

  final double _size;
  final bool horizontal;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: horizontal ? _size : 0,
    height: horizontal ? 0 : _size,
  );
}
