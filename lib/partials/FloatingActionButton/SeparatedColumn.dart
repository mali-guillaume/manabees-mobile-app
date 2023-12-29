///this widget allows to have 2 separeted FloatingButton

import 'package:flutter/material.dart';

class SeparatedColumn extends StatelessWidget {
  const SeparatedColumn({
    Key? key,
    required this.separator,
    this.children = const [],
    this.mainAxisSize = MainAxisSize.max,
  });

  final Widget separator;
  final List<Widget> children;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: mainAxisSize,
      children: [
        ..._buildChildren(),
      ],
    );
  }

  Iterable<Widget> _buildChildren() sync* {
    for (var i = 0; i < children.length; i++) {
      yield children[i];
      if (i < children.length - 1) yield separator;
    }
  }
}