import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/google_classroom_service.dart';

part 'google_classroom_provider.g.dart';

@riverpod
GoogleClassroomService googleClassroomService(GoogleClassroomServiceRef ref) {
  return GoogleClassroomService();
}

@Riverpod(keepAlive: true)
class ClassroomCourses extends _$ClassroomCourses {
  @override
  Future<List<ClassroomCourse>> build() async {
    final service = ref.read(googleClassroomServiceProvider);
    return service.fetchCourses();
  }
}

@riverpod
Future<List<ClassroomMaterial>> classroomMaterials(
    ClassroomMaterialsRef ref,
    String courseId,
    ) async {
  final service =
  ref.read(googleClassroomServiceProvider);

  return service.fetchCourseFiles(courseId);
}