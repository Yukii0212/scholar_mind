import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholar_mind/features/grades/widgets/dialogs/semester/create_semester_dialog.dart';

void main() {
  testWidgets('exact date fields fit inside a compact semester dialog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (_) => const CreateSemesterDialog(),
                      );
                    },
                    child: const Text('Open dialog'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Specify exact dates'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Specify exact dates'));
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonFormField<int>), findsNWidgets(6));
    expect(tester.takeException(), isNull);

    for (final dropdown
        in find.byType(DropdownButtonFormField<int>).evaluate()) {
      final bounds = tester.getRect(find.byElementPredicate(
        (element) => element == dropdown,
      ));
      expect(bounds.left, greaterThanOrEqualTo(0));
      expect(bounds.right, lessThanOrEqualTo(320));
    }
  });
}
