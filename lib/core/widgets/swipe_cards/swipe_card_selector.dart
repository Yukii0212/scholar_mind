import 'package:flutter/material.dart';

import 'swipe_card_item.dart';

class SwipeCardSelector extends StatelessWidget {
  const SwipeCardSelector({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<SwipeCardItem> items;

  final int currentIndex;

  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: items.length,
        separatorBuilder: (_, __) =>
        const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];

          return ListTile(
            leading: Icon(item.icon),

            title: Text(item.title),

            trailing: index == currentIndex
                ? const Icon(
              Icons.check,
            )
                : null,

            onTap: () {
              Navigator.pop(context);

              onSelected(index);
            },
          );
        },
      ),
    );
  }
}