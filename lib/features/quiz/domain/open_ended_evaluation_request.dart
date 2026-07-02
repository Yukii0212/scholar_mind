class OpenEndedEvaluationRequest {
  const OpenEndedEvaluationRequest({
    required this.questionIndex,
    required this.question,
    required this.sampleAnswer,
    required this.studentAnswer,
  });

  final int questionIndex;

  final String question;

  final String sampleAnswer;

  final String studentAnswer;

  Map<String, dynamic> toJson() {
    return {
      'questionIndex': questionIndex,
      'question': question,
      'sampleAnswer': sampleAnswer,
      'studentAnswer': studentAnswer,
    };
  }
}