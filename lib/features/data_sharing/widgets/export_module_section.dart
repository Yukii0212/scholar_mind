import 'package:flutter/material.dart';

class ExportModuleSection extends StatefulWidget {
  const ExportModuleSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<ExportModuleSection> createState() =>
      _ExportModuleSectionState();
}

class _ExportModuleSectionState
    extends State<ExportModuleSection> {

  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Column(
        children: [

          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            borderRadius:
            BorderRadius.circular(12),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                children: [

                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme
                          .textTheme
                          .titleMedium,
                    ),
                  ),

                  AnimatedRotation(
                    duration:
                    const Duration(
                      milliseconds: 200,
                    ),
                    turns: _expanded
                        ? 0.5
                        : 0,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild:
            const SizedBox.shrink(),
            secondChild: Padding(
              padding:
              const EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: 12,
              ),
              child: widget.child,
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