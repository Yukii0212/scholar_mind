import 'package:flutter/material.dart';

class ExportCartItemActions
    extends StatelessWidget {
  const ExportCartItemActions({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}