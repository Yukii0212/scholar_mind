import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleClassroomService {
  static const _scopes = [
    'https://www.googleapis.com/auth/classroom.courses.readonly',
    'https://www.googleapis.com/auth/classroom.courseworkmaterials.readonly',
    'https://www.googleapis.com/auth/drive.readonly',
  ];

  final GoogleSignIn _googleSignIn =
  GoogleSignIn(
    scopes: _scopes,
  );

  Future<List<ClassroomCourse>>
  fetchCourses() async {
    final user =
        await _googleSignIn.signInSilently() ??
            await _googleSignIn.signIn();

    if (user == null) {
      return [];
    }

    final auth =
    await user.authentication;

    final response =
    await http.get(
      Uri.parse(
        'https://classroom.googleapis.com/v1/courses',
      ),
      headers: {
        'Authorization':
        'Bearer ${auth.accessToken}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load courses',
      );
    }

    final data =
    jsonDecode(response.body);

    final courses =
        (data['courses'] as List?)
            ?.cast<Map<String, dynamic>>() ??
            [];

    return courses
        .map(
      ClassroomCourse.fromJson,
    )
        .toList();
  }

  Future<List<ClassroomMaterial>>
  fetchCourseFiles(
      String courseId,
      ) async {
    final user =
        await _googleSignIn
            .signInSilently() ??
            await _googleSignIn.signIn();

    if (user == null) {
      return [];
    }

    final auth =
    await user.authentication;

    final response =
    await http.get(
      Uri.parse(
        'https://classroom.googleapis.com/v1/courses/$courseId/courseWorkMaterials',
      ),
      headers: {
        'Authorization':
        'Bearer ${auth.accessToken}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load materials',
      );
    }

    final data =
    jsonDecode(response.body);

    final materials =
        (data['courseWorkMaterial']
        as List?)
            ?.cast<Map<String, dynamic>>() ??
            [];

    final result =
    <ClassroomMaterial>[];

    for (final material in materials) {
      final files =
      <ClassroomDriveFile>[];

      final attachments =
          material['materials']
          as List? ??
              [];

      for (final attachment
      in attachments) {
        final driveFile =
        attachment['driveFile'];

        if (driveFile == null) {
          continue;
        }

        final driveFileData =
        driveFile['driveFile'];

        files.add(
          ClassroomDriveFile(
            id:
            driveFileData['id'],
            title:
            driveFileData['title'] ??
                'Untitled',
          ),
        );
      }

      if (files.isEmpty) {
        continue;
      }

      result.add(
        ClassroomMaterial(
          id:
          material['id'],
          title:
          material['title'] ??
              'Untitled',
          files: files,
        ),
      );
    }

    return result;
  }
}

class ClassroomCourse {
  ClassroomCourse({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory ClassroomCourse.fromJson(
      Map<String, dynamic> json,
      ) {
    return ClassroomCourse(
      id: json['id'],
      name: json['name'] ?? 'Untitled',
    );
  }
}

class ClassroomMaterial {
  ClassroomMaterial({
    required this.id,
    required this.title,
    required this.files,
  });

  final String id;
  final String title;
  final List<ClassroomDriveFile> files;
}

class ClassroomDriveFile {
  ClassroomDriveFile({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}