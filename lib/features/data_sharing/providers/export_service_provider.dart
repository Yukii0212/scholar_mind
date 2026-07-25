import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/export_service.dart';

part 'export_service_provider.g.dart';

@riverpod
ExportService exportService(
    ExportServiceRef ref,
    ) {
  return ExportService();
}