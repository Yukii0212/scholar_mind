import 'dart:io';

import 'package:archive/archive.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';

import '../../notes/domain/note_item.dart';
import '../../notes/services/file_cache_service.dart';

class ProcessedStudyMaterial {
  const ProcessedStudyMaterial({
    required this.note,
    required this.text,
  });

  final NoteItem note;
  final String text;
}

class StudyMaterialPreprocessor {
  const StudyMaterialPreprocessor();

  Future<Map<String, ProcessedStudyMaterial>> process(
      List<NoteItem> notes,
      ) async {
    final processed =
    <String, ProcessedStudyMaterial>{};

    for (final note in notes) {
      await FileCacheService.ensureCacheExists(note);

      final file = await FileCacheService.getFile(
        storagePath: note.storagePath,
        fileName: note.name,
      );

      final text = switch (note.extension.toLowerCase()) {
        'pdf' => await _extractPdf(file),

        'ppt' || 'pptx' => await _extractPowerPoint(file),

        _ => '',
      };

      processed[note.id] = ProcessedStudyMaterial(
        note: note,
        text: _cleanText(text),
      );
    }

    return processed;
  }

  Future<String> _extractPdf(
      File file,
      ) async {
    final document = PdfDocument(
      inputBytes: await file.readAsBytes(),
    );

    try {
      final extractor = PdfTextExtractor(
        document,
      );

      return extractor.extractText();
    } finally {
      document.dispose();
    }
  }

  Future<String> _extractPowerPoint(
      File file,
      ) async {
    final archive = ZipDecoder().decodeBytes(
      await file.readAsBytes(),
    );

    final buffer = StringBuffer();

    for (final entry in archive.files) {
      if (!entry.name.startsWith(
        'ppt/slides/',
      )) {
        continue;
      }

      if (!entry.name.endsWith('.xml')) {
        continue;
      }

      final document = XmlDocument.parse(
        String.fromCharCodes(
          entry.content as List<int>,
        ),
      );

      for (final node in document.findAllElements('a:t')) {
        buffer.writeln(node.innerText);
      }

      buffer.writeln();
    }

    return buffer.toString();
  }

  String _cleanText(
      String text,
      ) {
    var cleaned = text
        .replaceAll('\r', '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();

    const maxCharacters = 30000;

    if (cleaned.length > maxCharacters) {
      cleaned = cleaned.substring(
        0,
        maxCharacters,
      );
    }

    return cleaned;
  }
}