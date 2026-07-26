import 'package:flutter/material.dart';

class ExportCartItemMetadata
    extends StatelessWidget {
  const ExportCartItemMetadata({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: children,
    );
  }
}