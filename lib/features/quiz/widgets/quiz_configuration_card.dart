import 'package:flutter/material.dart';

class QuizConfigurationCard extends StatelessWidget {
  const QuizConfigurationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Configuration',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            SizedBox(height: 20),

            ListTile(
              leading: Icon(Icons.format_list_numbered),
              title: Text('Question Count'),
              subtitle: Text('10 Questions'),
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.trending_up),
              title: Text('Difficulty'),
              subtitle: Text('Medium'),
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.checklist),
              title: Text('Question Types'),
              subtitle: Text('Multiple Choice, True / False, Open Ended'),
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.balance),
              title: Text('Weighting'),
              subtitle: Text('Default'),
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.edit_note),
              title: Text('Extra Instructions'),
              subtitle: Text('None'),
            ),
          ],
        ),
      ),
    );
  }
}