import 'package:flutter/material.dart';

import 'export_cart_module_header.dart';

class ExportCartModuleCard extends StatefulWidget {
  const ExportCartModuleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    this.initiallyExpanded = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  State<ExportCartModuleCard> createState() =>
      _ExportCartModuleCardState();
}

class _ExportCartModuleCardState
    extends State<ExportCartModuleCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ExportCartModuleHeader(
            icon: widget.icon,
            title: widget.title,
            subtitle: widget.subtitle,
            expanded: _expanded,
            onPressed: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: widget.children,
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(
              milliseconds: 200,
            ),
          ),
        ],
      ),
    );
  }
}