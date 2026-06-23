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