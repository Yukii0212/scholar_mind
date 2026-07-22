import 'package:flutter/material.dart';

class TrashSection extends StatelessWidget {

  const TrashSection({

    super.key,

    required this.onRestoreAll,

    required this.onDeleteAll,

    required this.folders,

    required this.files,

  });

  final VoidCallback onRestoreAll;

  final VoidCallback onDeleteAll;

  final List<Widget> folders;

  final List<Widget> files;

  @override
  Widget build(BuildContext context) {

    return Card(

      child: Padding(

        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          12,
          20,
        ),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Row(

              children: [

                Expanded(

                  child: Text(

                    'Trash',

                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,

                  ),

                ),

                PopupMenuButton<String>(

                  itemBuilder: (_) => const [

                    PopupMenuItem(

                      value: 'restore_all',

                      child: Text(
                        'Restore All',
                      ),

                    ),

                    PopupMenuItem(

                      value: 'delete_all',

                      child: Text(
                        'Empty Trash',
                      ),

                    ),

                  ],

                  onSelected: (value) {

                    switch (value) {

                      case 'restore_all':

                        onRestoreAll();

                        break;

                      case 'delete_all':

                        onDeleteAll();

                        break;

                    }

                  },

                ),

              ],

            ),
            const SizedBox(height: 24),

            if (folders.isEmpty && files.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 56,
                      color: Theme.of(context)
                          .colorScheme
                          .outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No items in Trash',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Deleted notes and folders will appear here.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                  ],
                ),
              ),

            if (folders.isNotEmpty) ...[

              const SizedBox(height: 20),

              Text(

                'Folders',

                style: Theme.of(context)
                    .textTheme
                    .titleMedium,

              ),

              const SizedBox(height: 12),

              ...folders,

            ],

            if (files.isNotEmpty) ...[

              const SizedBox(height: 24),

              Text(

                'Files',

                style: Theme.of(context)
                    .textTheme
                    .titleMedium,

              ),

              const SizedBox(height: 12),

              ...files,

            ],
          ],

        ),

      ),

    );

  }

}