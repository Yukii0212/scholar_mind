import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/export/export_module.dart';

part 'export_library_provider.g.dart';

@riverpod
Future<List<ExportModule>> exportLibrary(
    ExportLibraryRef ref,
    ) async {
  /// Populated in Sprint 2.
  ///
  /// This provider will aggregate data from
  /// Notes
  /// Quiz
  /// Flashcards
  /// Countdown
  /// etc.
  return const [];
}