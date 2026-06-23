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
