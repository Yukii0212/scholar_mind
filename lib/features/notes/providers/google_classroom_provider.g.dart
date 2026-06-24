// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_classroom_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$googleClassroomServiceHash() =>
    r'93811f9aed6d150cd22ce603beec2fb5230c981f';

/// See also [googleClassroomService].
@ProviderFor(googleClassroomService)
final googleClassroomServiceProvider =
    AutoDisposeProvider<GoogleClassroomService>.internal(
  googleClassroomService,
  name: r'googleClassroomServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$googleClassroomServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GoogleClassroomServiceRef
    = AutoDisposeProviderRef<GoogleClassroomService>;
String _$classroomMaterialsHash() =>
    r'131f804cac2d5874a70ae9c61e7cff277d48cbe3';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [classroomMaterials].
@ProviderFor(classroomMaterials)
const classroomMaterialsProvider = ClassroomMaterialsFamily();

/// See also [classroomMaterials].
class ClassroomMaterialsFamily
    extends Family<AsyncValue<List<ClassroomMaterial>>> {
  /// See also [classroomMaterials].
  const ClassroomMaterialsFamily();

  /// See also [classroomMaterials].
  ClassroomMaterialsProvider call(
    String courseId,
  ) {
    return ClassroomMaterialsProvider(
      courseId,
    );
  }

  @override
  ClassroomMaterialsProvider getProviderOverride(
    covariant ClassroomMaterialsProvider provider,
  ) {
    return call(
      provider.courseId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'classroomMaterialsProvider';
}

/// See also [classroomMaterials].
class ClassroomMaterialsProvider
    extends AutoDisposeFutureProvider<List<ClassroomMaterial>> {
  /// See also [classroomMaterials].
  ClassroomMaterialsProvider(
    String courseId,
  ) : this._internal(
          (ref) => classroomMaterials(
            ref as ClassroomMaterialsRef,
            courseId,
          ),
          from: classroomMaterialsProvider,
          name: r'classroomMaterialsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$classroomMaterialsHash,
          dependencies: ClassroomMaterialsFamily._dependencies,
          allTransitiveDependencies:
              ClassroomMaterialsFamily._allTransitiveDependencies,
          courseId: courseId,
        );

  ClassroomMaterialsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.courseId,
  }) : super.internal();

  final String courseId;

  @override
  Override overrideWith(
    FutureOr<List<ClassroomMaterial>> Function(ClassroomMaterialsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClassroomMaterialsProvider._internal(
        (ref) => create(ref as ClassroomMaterialsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        courseId: courseId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ClassroomMaterial>> createElement() {
    return _ClassroomMaterialsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClassroomMaterialsProvider && other.courseId == courseId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, courseId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ClassroomMaterialsRef
    on AutoDisposeFutureProviderRef<List<ClassroomMaterial>> {
  /// The parameter `courseId` of this provider.
  String get courseId;
}

class _ClassroomMaterialsProviderElement
    extends AutoDisposeFutureProviderElement<List<ClassroomMaterial>>
    with ClassroomMaterialsRef {
  _ClassroomMaterialsProviderElement(super.provider);

  @override
  String get courseId => (origin as ClassroomMaterialsProvider).courseId;
}

String _$classroomCoursesHash() => r'334c7e10be3e2108d7b3bfb201b5b421239771d8';

/// See also [ClassroomCourses].
@ProviderFor(ClassroomCourses)
final classroomCoursesProvider =
    AsyncNotifierProvider<ClassroomCourses, List<ClassroomCourse>>.internal(
  ClassroomCourses.new,
  name: r'classroomCoursesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$classroomCoursesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ClassroomCourses = AsyncNotifier<List<ClassroomCourse>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
