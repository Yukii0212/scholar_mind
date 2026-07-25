import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/export_search_provider.dart';


class ExportSearchBar extends ConsumerStatefulWidget {
  const ExportSearchBar({
    super.key,
  });

  @override
  ConsumerState<ExportSearchBar> createState() =>
      _ExportSearchBarState();
}

class _ExportSearchBarState
    extends ConsumerState<ExportSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: ref.read(exportSearchProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: _controller,
      leading: const Icon(Icons.search_rounded),
      hintText: 'Search study materials...',
      onChanged: (value) {
        ref
            .read(exportSearchProvider.notifier)
            .update(value);
      },
      trailing: [
        if (_controller.text.isNotEmpty)
          IconButton(
            onPressed: () {
              _controller.clear();

              ref
                  .read(exportSearchProvider.notifier)
                  .clear();

              setState(() {});
            },
            icon: const Icon(Icons.close_rounded),
          ),
      ],
    );
  }
}