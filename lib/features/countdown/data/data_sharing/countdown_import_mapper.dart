import '../../../data_sharing/domain/models/share/share_resource.dart';

class CountdownImportMapper {
  const CountdownImportMapper();

  Map<String, dynamic> payloadOf(
      ShareResource resource,
      ) {
    return resource.payload;
  }
}
