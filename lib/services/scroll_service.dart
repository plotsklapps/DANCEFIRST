import 'dart:ui';

import 'package:flutter/material.dart';

class ScrollService extends StatelessWidget {
  const ScrollService({
    required this.child,
    this.scrollDirection = Axis.vertical,
    super.key,
  });

  final Widget child;
  final Axis scrollDirection;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(
        dragDevices: <PointerDeviceKind>{
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.invertedStylus,
        },
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: scrollDirection,
        child: child,
      ),
    );
  }
}
