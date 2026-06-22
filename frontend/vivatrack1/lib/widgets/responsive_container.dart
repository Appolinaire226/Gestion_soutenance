import 'package:flutter/material.dart';

class ResponsivePageContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ResponsivePageContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final containerWidth = maxWidth >= 1400
            ? 1200.0
            : maxWidth >= 1100
            ? 960.0
            : maxWidth >= 900
            ? 760.0
            : maxWidth >= 600
            ? 560.0
            : maxWidth;

        return Center(
          child: Container(
            padding: padding,
            constraints: BoxConstraints(maxWidth: containerWidth),
            child: child,
          ),
        );
      },
    );
  }
}
