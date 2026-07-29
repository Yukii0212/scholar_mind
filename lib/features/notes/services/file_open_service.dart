import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../domain/note_item.dart';
import '../screens/office_document_viewer_screen.dart';
import '../screens/pdf_viewer_screen.dart';
import 'file_cache_service.dart';

class FileOpenService {
  static Future<void> openUploadedFile(
      BuildContext context,
      NoteItem note,
      ) async {
    if (note.isInternal) {
      return;
    }

    final extension = note.extension.toLowerCase();

    if (extension == 'pdf') {
      await _openPdf(context, note);
      return;
    }

    if (extension == 'ppt' || extension == 'pptx') {
      await _openOfficeDocument(context, note);
      return;
    }

    await openExternally(note);
  }

  static Future<void> _openPdf(
      BuildContext context,
      NoteItem note,
      ) async {
    final file = await _ensureCachedFile(note);

    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          file: file,
          title: note.displayFileName,
        ),
      ),
    );
  }

  static Future<void> _openOfficeDocument(
      BuildContext context,
      NoteItem note,
      ) async {
    final url =
        await FirebaseStorage.instance.ref(note.storagePath).getDownloadURL();

    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OfficeDocumentViewerScreen(
          fileUrl: url,
          title: note.displayFileName,
          onOpenExternally: () => openExternally(note),
        ),
      ),
    );
  }

  /// Downloads (if needed) and opens the file in whatever app the OS
  /// hands it off to. Used both as the default path for file types with
  /// no in-app viewer, and as the offline/failure fallback from the
  /// in-app viewers.
  static Future<void> openExternally(NoteItem note) async {
    final file = await _ensureCachedFile(note);

    await OpenFilex.open(file.path);
  }

  static Future<File> _ensureCachedFile(NoteItem note) async {
    if (await FileCacheService.exists(
      note.storagePath,
      note.displayFileName,
    )) {
      return FileCacheService.getFile(
        storagePath: note.storagePath,
        fileName: note.displayFileName,
      );
    }

    return FileCacheService.downloadFromFirebase(
      storagePath: note.storagePath,
      fileName: note.displayFileName,
    );
  }
}
