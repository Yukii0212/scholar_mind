import 'package:flutter/material.dart';

class ExportCartItemTile extends StatelessWidget {
  const ExportCartItemTile({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        16,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}