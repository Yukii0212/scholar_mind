import 'dart:convert';
import 'dart:typed_data';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../domain/drive_item.dart';

class GoogleClassroomService {
  GoogleClassroomService(
      this._googleSignIn,
      );

  final GoogleSignIn _googleSignIn;

  static const _scopes = [
    'https://www.googleapis.com/auth/classroom.courses.readonly',
    'https://www.googleapis.com/auth/classroom.courseworkmaterials.readonly',
    'https://www.googleapis.com/auth/drive.readonly',
  ];

  Future<Uint8List> downloadDriveFile(
      String fileId,
      ) async {
    final user =
        await _googleSignIn.signInSilently() ??
            await _googleSignIn.signIn();

    if (user == null) {
      throw Exception(
        'User not signed in',
      );
    }

    final auth =
    await user.authentication;

    final response =
    await http.get(
      Uri.parse(
        'https://www.googleapis.com/drive/v3/files/$fileId?alt=media',
      ),
      headers: {
        'Authorization':
        'Bearer ${auth.accessToken}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to download file',
      );
    }

    return response.bodyBytes;
  }

  Future<List<DriveItem>> fetchDriveItems(
      String folderId,
      ) async {
    final user =
        await _googleSignIn.signInSilently() ??
            await _googleSignIn.signIn();

    if (user == null) {
      return [];
    }

    final auth =
    await user.authentication;

    final response = await http.get(
      Uri.parse(
        'https://www.googleapis.com/drive/v3/files'
            '?q='
            '\'${folderId == 'root' ? 'root' : folderId}\' in parents '
            'and trashed=false'
            '&fields=files('
            'id,'
            'name,'
            'mimeType,'
            'shortcutDetails(targetId,targetMimeType)'
            ')'
            '&orderBy=folder,name',
      ),
      headers: {
        'Authorization':
        'Bearer ${auth.accessToken}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load Google Drive files.',
      );
    }

    final data =
    jsonDecode(response.body);

    final files =
        (data['files'] as List?)
            ?.cast<Map<String, dynamic>>() ??
            [];

    return files
        .map(DriveItem.fromJson)
        .toList();
  }

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
        'https://classroom.googleapis.com/v1/courses?courseStates=ACTIVE&courseStates=ARCHIVED',
      ),
      headers: {
        'Authorization':
        'Bearer ${auth.accessToken}',
      },
    );

    if (response.statusCode != 200) {
      print('Status: ${response.statusCode}');
      print(response.body);

      throw Exception(
        'Failed to load courses (${response.statusCode})',
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
            id: driveFileData['id'],
            title:
            driveFileData['title'] ??
                'Untitled',
            alternateLink:
            driveFileData['alternateLink'] ??
                '',
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
    required this.courseState,
  });

  final String id;
  final String name;
  final String courseState;

  factory ClassroomCourse.fromJson(
      Map<String, dynamic> json,
      ) {
    return ClassroomCourse(
      id: json['id'],
      name: json['name'] ?? 'Untitled',
      courseState:
      json['courseState'] ?? 'ACTIVE',
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
    required this.alternateLink,
  });

  final String id;
  final String title;
  final String alternateLink;
}