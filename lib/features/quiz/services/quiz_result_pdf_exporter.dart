import 'dart:io';
import 'dart:ui';

import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../domain/question_type.dart';
import '../domain/quiz_answer.dart';
import '../domain/quiz_response.dart';

/// Renders a completed quiz attempt (questions, the student's answers, and
/// how they were graded) to a PDF file, so it can be shared outside the
/// app the same way `ShareQrView` shares a QR code image.
class QuizResultPdfExporter {
  const QuizResultPdfExporter();

  Future<File> export({
    required QuizResponse quiz,
    required Map<int, QuizAnswer> answers,
  }) async {
    final document = PdfDocument();

    final titleFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      20,
      style: PdfFontStyle.bold,
    );
    final headingFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      13,
      style: PdfFontStyle.bold,
    );
    final labelFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      10,
      style: PdfFontStyle.bold,
    );
    final bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final mutedBrush = PdfSolidBrush(PdfColor(110, 110, 110));
    final correctBrush = PdfSolidBrush(PdfColor(34, 139, 34));
    final incorrectBrush = PdfSolidBrush(PdfColor(200, 40, 40));

    var page = document.pages.add();
    var bounds = Rect.fromLTWH(
      0,
      0,
      page.getClientSize().width,
      page.getClientSize().height,
    );

    double y = 0;

    PdfLayoutResult? draw(
      String text,
      PdfFont font, {
      PdfBrush? brush,
      double spacingAfter = 6,
    }) {
      if (text.isEmpty) return null;

      final result = PdfTextElement(text: text, font: font, brush: brush)
          .draw(
        page: page,
        bounds: Rect.fromLTWH(0, y, bounds.width, 0),
        format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate),
      );

      page = result!.page;
      y = result.bounds.bottom + spacingAfter;

      return result;
    }

    int total = quiz.questions.length;
    int objectiveTotal = 0;
    int correct = 0;
    int essayScore = 0;
    int essayMax = 0;
    int openEndedCount = 0;

    for (var i = 0; i < total; i++) {
      final question = quiz.questions[i];
      final answer = answers[i];

      if (question.type == QuestionType.openEnded) {
        openEndedCount++;
        essayScore += answer?.aiScore ?? 0;
        essayMax += answer?.aiMaxScore ?? 0;
        continue;
      }

      objectiveTotal++;

      if (question.correctAnswerIndex != null &&
          answer?.selectedOptionIndex == question.correctAnswerIndex) {
        correct++;
      }
    }

    draw(quiz.title, titleFont, spacingAfter: 4);
    draw(
      'Exported ${DateTime.now().toLocal().toString().split('.').first}',
      bodyFont,
      brush: mutedBrush,
      spacingAfter: 16,
    );

    if (objectiveTotal > 0) {
      final percentage = ((correct / objectiveTotal) * 100).round();

      draw(
        'Score: $percentage% ($correct / $objectiveTotal correct)',
        headingFont,
        spacingAfter: 4,
      );
    }

    if (openEndedCount > 0) {
      draw(
        'Open-ended score: $essayScore / $essayMax',
        headingFont,
        spacingAfter: 4,
      );
    }

    y += 10;

    for (var i = 0; i < total; i++) {
      final question = quiz.questions[i];
      final answer = answers[i];

      draw('Question ${i + 1}', headingFont, spacingAfter: 4);
      draw(question.question, bodyFont, spacingAfter: 8);

      if (question.type != QuestionType.openEnded) {
        final selectedIndex = answer?.selectedOptionIndex;
        final isCorrect = selectedIndex != null &&
            selectedIndex == question.correctAnswerIndex;

        draw('Your Answer', labelFont, spacingAfter: 2);
        draw(
          selectedIndex == null
              ? 'Not Answered'
              : question.options[selectedIndex],
          bodyFont,
          brush: selectedIndex == null
              ? mutedBrush
              : (isCorrect ? correctBrush : incorrectBrush),
          spacingAfter: 6,
        );

        if (!isCorrect && question.correctAnswerIndex != null) {
          draw('Correct Answer', labelFont, spacingAfter: 2);
          draw(
            question.options[question.correctAnswerIndex!],
            bodyFont,
            brush: correctBrush,
            spacingAfter: 6,
          );
        }

        draw('Explanation', labelFont, spacingAfter: 2);
        draw(question.explanation, bodyFont, spacingAfter: 6);
      } else {
        draw('Your Answer', labelFont, spacingAfter: 2);
        draw(
          answer?.openEndedAnswer.isNotEmpty == true
              ? answer!.openEndedAnswer
              : 'No answer provided.',
          bodyFont,
          spacingAfter: 6,
        );

        draw(
          'AI Score: ${answer?.aiScore ?? 0} / ${answer?.aiMaxScore ?? 0}',
          labelFont,
          spacingAfter: 4,
        );

        draw('AI Feedback', labelFont, spacingAfter: 2);
        draw(
          answer?.aiFeedback ?? 'No feedback available.',
          bodyFont,
          spacingAfter: 6,
        );
      }

      y += 10;
    }

    final bytes = await document.save();
    document.dispose();

    final directory = await getTemporaryDirectory();
    final safeName = quiz.title
        .replaceAll(RegExp(r'[^A-Za-z0-9 _-]'), '')
        .trim();

    final file = File(
      '${directory.path}/${safeName.isEmpty ? 'quiz_result' : safeName}.pdf',
    );

    await file.writeAsBytes(bytes, flush: true);

    return file;
  }
}
