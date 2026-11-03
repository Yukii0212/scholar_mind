import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholar_mind/features/grades/data/models/course_model.dart';
import 'package:scholar_mind/features/grades/widgets/dialogs/course/edit_course_dialog.dart';

void main() {
  testWidgets('copy review returns the edited course name', (tester) async {
    final now = DateTime(2026, 1, 1);
    final source = CourseModel(
      id: '',
      ownerId: 'user-1',
      semesterId: 'semester-1',
      name: 'Old Course Name',
      targetScore: 80,
      createdAt: now,
      updatedAt: now,
    );
    CourseModel? reviewed;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  reviewed = await showDialog<CourseModel>(
                    context: context,
                    builder: (_) => EditCourseDialog(
                      course: source,
                      isImport: true,
                      title: 'Review Copied Course',
                    ),
                  );
                },
                child: const Text('Copy course'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Copy course'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'New Course Name',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      '',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(reviewed?.name, 'New Course Name');
    expect(reviewed?.targetScore, isNull);
  });
}
