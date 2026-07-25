import '../collection/data_share_collector.dart';
import '../domain/models/share/share_resource_type.dart';

class DataShareCollectionRegistry {
  DataShareCollectionRegistry._();

  static final instance =
  DataShareCollectionRegistry._();

  final Map<ShareResourceType, DataShareCollector>
  _collectors = {};

  void register(
      DataShareCollector collector,
      ) {
    _collectors[collector.resourceType] =
        collector;
  }

  DataShareCollector? collectorFor(
      ShareResourceType type,
      ) {
    return _collectors[type];
  }

  Iterable<DataShareCollector> get collectors =>
      _collectors.values;
}