import 'package:flutter/material.dart';

class AssessmentEntryTile extends StatelessWidget {
  const AssessmentEntryTile({
    super.key,
    required this.title,
    required this.placeholder,
    required this.icon,
    this.savedScore,
    this.savedPercentage,
    this.onTap,
  });

  final String title;

  final String placeholder;

  final IconData icon;

  final String? savedScore;

  final String? savedPercentage;

  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .labelLarge,
        ),

        const SizedBox(height: 2),

        InkWell(
          onTap: () async {
            await onTap?.call();
          },
          borderRadius:
          BorderRadius.circular(12),
          child: Ink(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context)
                    .dividerColor,
              ),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: savedScore == null
                      ? Text(
                    placeholder,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  )
                      : Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Text(
                        savedScore!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      if (savedPercentage !=
                          null)
                        Text(
                          savedPercentage!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}