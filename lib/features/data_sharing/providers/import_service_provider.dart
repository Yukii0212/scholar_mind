import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/import_service.dart';

part 'import_service_provider.g.dart';

@riverpod
ImportService importService(
    ImportServiceRef ref,
    ) {
  return ImportService();
}