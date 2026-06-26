import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  DeviceIdService._();

  static const _deviceIdKey = 'device_id';

  static const _uuid = Uuid();

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();

    final existingId = prefs.getString(_deviceIdKey);

    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }

    final deviceId = _uuid.v4();

    await prefs.setString(
      _deviceIdKey,
      deviceId,
    );

    return deviceId;
  }
}