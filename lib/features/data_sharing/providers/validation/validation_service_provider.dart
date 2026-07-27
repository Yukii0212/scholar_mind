import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/validation_service.dart';

part 'validation_service_provider.g.dart';

@riverpod
ValidationService validationService(
    ValidationServiceRef ref,
    ) {
  return const ValidationService();
}