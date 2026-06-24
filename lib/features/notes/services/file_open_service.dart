import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/note_item.dart';

class FileOpenService {
  static Future<void> openUploadedFile(NoteItem note) async {
    final storageRef = FirebaseStorage.instance.ref(note.storagePath);
    final downloadUrl = await storageRef.getDownloadURL();
    final response = await http.get(Uri.parse(downloadUrl));

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${note.name}';
    final file = File(filePath);

    await file.writeAsBytes(response.bodyBytes);
    await OpenFilex.open(file.path);
  }
}