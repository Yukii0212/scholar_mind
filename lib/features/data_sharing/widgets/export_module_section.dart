import 'package:flutter/material.dart';

class ExportModuleSection extends StatefulWidget {
  const ExportModuleSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.initiallyExpanded = false,
  });

  final String title;
  final String subtitle;
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

    return Container(
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Column(
        children: [

          InkWell(
            borderRadius:
            BorderRadius.circular(20),
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Padding(
              padding:
              const EdgeInsets.all(20),
              child: Row(
                children: [

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        Text(
                          widget.title,
                          style: theme
                              .textTheme
                              .titleLarge,
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          widget.subtitle,
                          style: theme
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            color: theme
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  AnimatedRotation(
                    duration:
                    const Duration(
                      milliseconds: 200,
                    ),
                    turns:
                    _expanded ? .5 : 0,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
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
              const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16,
              ),
              child: widget.child,
            ),
            crossFadeState:
            _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration:
            const Duration(
              milliseconds: 200,
            ),
          ),
        ],
      ),
    );
  }
}