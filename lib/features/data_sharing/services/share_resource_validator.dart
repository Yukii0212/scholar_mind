import '../domain/models/share/share_resource.dart';
import '../domain/models/share/share_resource_type.dart';
import '../domain/models/validation/validation_result.dart';

class ShareResourceValidator {
  ShareResourceValidator(
    this.resource, {
    required Set<ShareResourceType> supportedTypes,
    int supportedVersion = 1,
  }) {
    if (!supportedTypes.contains(resource.resourceType)) {
      _errors.add(
        'Resource "${resource.resourceId}" has unsupported type '
        '"${resource.resourceType.value}".',
      );
    }

    if (resource.resourceVersion != supportedVersion) {
      _errors.add(
        'Resource "${resource.resourceId}" uses unsupported version '
        '${resource.resourceVersion}.',
      );
    }

    if (resource.resourceId.trim().isEmpty) {
      _errors.add('Resource identifier must not be empty.');
    }

    if (resource.metadata.displayName.trim().isEmpty) {
      _errors.add(
        'Resource "${resource.resourceId}" must have a display name.',
      );
    }
  }

  final ShareResource resource;
  final List<String> _errors = [];
  final List<String> _warnings = [];

  String? requireString(
    String key, {
    bool allowEmpty = false,
  }) {
    final value = resource.payload[key];

    if (value is! String || (!allowEmpty && value.trim().isEmpty)) {
      _invalidField(key, allowEmpty ? 'a string' : 'a non-empty string');
      return null;
    }

    return value;
  }

  String? optionalString(String key) {
    final value = resource.payload[key];

    if (value == null) {
      return null;
    }

    if (value is! String) {
      _invalidField(key, 'a string or null');
      return null;
    }

    return value;
  }

  bool? requireBool(String key) {
    final value = resource.payload[key];

    if (value is! bool) {
      _invalidField(key, 'a boolean');
      return null;
    }

    return value;
  }

  void optionalBool(String key) {
    final value = resource.payload[key];

    if (value != null && value is! bool) {
      _invalidField(key, 'a boolean or null');
    }
  }

  int? requireInt(
    String key, {
    int? minimum,
  }) {
    final value = resource.payload[key];

    if (value is! int || (minimum != null && value < minimum)) {
      _invalidField(
        key,
        minimum == null ? 'an integer' : 'an integer of at least $minimum',
      );
      return null;
    }

    return value;
  }

  num? requireNumber(
    String key, {
    num? minimum,
    bool allowZero = true,
  }) {
    final value = resource.payload[key];
    final belowMinimum = value is num && minimum != null && value < minimum;
    final disallowedZero = value is num && !allowZero && value == 0;

    if (value is! num || belowMinimum || disallowedZero) {
      _invalidField(key, 'a valid number');
      return null;
    }

    return value;
  }

  num? optionalNumber(String key) {
    final value = resource.payload[key];

    if (value == null) {
      return null;
    }

    if (value is! num) {
      _invalidField(key, 'a number or null');
      return null;
    }

    return value;
  }

  List<dynamic>? requireList(String key) {
    final value = resource.payload[key];

    if (value is! List<dynamic>) {
      _invalidField(key, 'a list');
      return null;
    }

    return value;
  }

  void optionalStringList(String key) {
    final value = resource.payload[key];

    if (value == null) {
      return;
    }

    if (value is! List || value.any((item) => item is! String)) {
      _invalidField(key, 'a list of strings or null');
    }
  }

  Map<String, dynamic>? requireMap(String key) {
    final value = resource.payload[key];

    if (value is! Map) {
      _invalidField(key, 'an object');
      return null;
    }

    try {
      return Map<String, dynamic>.from(value);
    } on TypeError {
      _invalidField(key, 'an object with string keys');
      return null;
    }
  }

  DateTime? requireDate(String key) {
    final value = requireString(key);

    if (value == null) {
      return null;
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      _invalidField(key, 'an ISO-8601 date');
    }

    return parsed;
  }

  void requireAllowedValue(
    String key,
    Iterable<String> allowedValues,
  ) {
    final value = requireString(key);

    if (value != null && !allowedValues.contains(value)) {
      _invalidField(key, 'one of ${allowedValues.join(', ')}');
    }
  }

  void addError(String message) {
    _errors.add('Resource "${resource.resourceId}": $message');
  }

  void addWarning(String message) {
    _warnings.add('Resource "${resource.resourceId}": $message');
  }

  ValidationResult result() {
    return ValidationResult(
      isValid: _errors.isEmpty,
      warnings: List<String>.unmodifiable(_warnings),
      errors: List<String>.unmodifiable(_errors),
    );
  }

  void _invalidField(String key, String expectation) {
    _errors.add(
      'Resource "${resource.resourceId}" field "$key" must be $expectation.',
    );
  }
}
