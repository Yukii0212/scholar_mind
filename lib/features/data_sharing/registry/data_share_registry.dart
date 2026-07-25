import 'data_share_handler.dart';

class DataShareRegistry {
  DataShareRegistry._();

  static final DataShareRegistry instance = DataShareRegistry._();

  final Map<String, DataShareHandler> _handlers = {};

  void register(DataShareHandler handler) {
    _handlers[handler.resourceType] = handler;
  }

  DataShareHandler? handlerFor(String resourceType) {
    return _handlers[resourceType];
  }

  Iterable<DataShareHandler> get handlers => _handlers.values;
}