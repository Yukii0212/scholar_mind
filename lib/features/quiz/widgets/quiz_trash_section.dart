import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizTrashSection extends ConsumerWidget {

  const QuizTrashSection({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Text(

              'Trash',

              style: Theme.of(context)
                  .textTheme
                  .titleLarge,

            ),

            const SizedBox(height: 16),

            const Center(

              child: Text(
                'Trash is empty.',
              ),

            ),

          ],

        ),

      ),

    );

  }

}