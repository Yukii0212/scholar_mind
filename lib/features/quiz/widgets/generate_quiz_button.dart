import 'package:flutter/material.dart';

class GenerateQuizButton extends StatelessWidget {

  const GenerateQuizButton({
    super.key,
    required this.onPressed,
    required this.onGenerateToFolder,
  });

  final VoidCallback? onPressed;

  final VoidCallback? onGenerateToFolder;

  @override
  Widget build(BuildContext context) {

    return FilledButton.icon(

      icon: const Icon(
        Icons.auto_awesome,
      ),

      label: const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 14,
        ),
        child: Text(
          'Generate AI Quiz',
        ),
      ),

      onPressed: () {

        showModalBottomSheet(

          context: context,

          builder: (_) {

            return SafeArea(

              child: Column(

                mainAxisSize: MainAxisSize.min,

                children: [

                  ListTile(

                    leading: const Icon(
                      Icons.auto_awesome,
                    ),

                    title: const Text(
                      'Generate in Root Folder',
                    ),

                    onTap: () {

                      Navigator.pop(context);

                      onPressed?.call();

                    },

                  ),

                  ListTile(

                    leading: const Icon(
                      Icons.folder,
                    ),

                    title: const Text(
                      'Choose Folder...',
                    ),

                    onTap: () {

                      Navigator.pop(context);

                      onGenerateToFolder?.call();

                    },

                  ),

                ],

              ),

            );

          },

        );

      },

    );

  }
}