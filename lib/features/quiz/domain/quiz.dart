import 'quiz_attempt.dart';

class Quiz {

  const Quiz({
    required this.id,
    required this.title,
    required this.attempts,
  });

  final String id;

  final String title;

  final List<QuizAttempt> attempts;

  Quiz copyWith({

    String? title,

    List<QuizAttempt>? attempts,

  }) {

    return Quiz(

      id: id,

      title: title ?? this.title,

      attempts:
      attempts ?? this.attempts,

    );

  }

}