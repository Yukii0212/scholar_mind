import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'export_search_provider.g.dart';

@riverpod
class ExportSearch extends _$ExportSearch {
  @override
  String build() => '';

  void update(String value) {
    state = value.trimLeft();
  }

  void clear() {
    state = '';
  }

  bool get hasQuery => state.trim().isNotEmpty;
}