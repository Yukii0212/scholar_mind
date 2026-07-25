import '../domain/models/share_method.dart';

abstract class TransportService {
  Future<void> send({
    required ShareMethod method,
    required List<int> payload,
  });
}