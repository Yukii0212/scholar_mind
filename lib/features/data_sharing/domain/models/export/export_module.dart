import 'export_item.dart';

class ExportModule {
  const ExportModule({
    required this.id,
    required this.title,
    required this.items,
    this.description,
  });

  final String id;

  final String title;

  final String? description;

  final List<ExportItem> items;

  int get itemCount => items.length;
}