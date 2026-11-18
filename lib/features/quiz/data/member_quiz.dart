class MemberQuiz {
  final int id;
  final String title;
  final String description;
  final int passingScore;
  final List<MemberQuizQuestion> questions;

  const MemberQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.passingScore,
    required this.questions,
  });

  factory MemberQuiz.fromJson(Map<String, dynamic> json) => MemberQuiz(
    id: (json['id'] as num?)?.toInt() ?? 0,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    passingScore: (json['passingScore'] as num?)?.toInt() ?? 0,
    questions: (json['questions'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) =>
              MemberQuizQuestion.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(),
  );
}

class MemberQuizQuestion {
  final int index;
  final String text;
  final List<MemberQuizChoice> choices;

  const MemberQuizQuestion({
    required this.index,
    required this.text,
    required this.choices,
  });

  factory MemberQuizQuestion.fromJson(Map<String, dynamic> json) =>
      MemberQuizQuestion(
        index: (json['index'] as num?)?.toInt() ?? 0,
        text: json['text'] as String? ?? '',
        choices: (json['choices'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (item) =>
                  MemberQuizChoice.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(),
      );
}

class MemberQuizChoice {
  final int index;
  final String text;
  const MemberQuizChoice({required this.index, required this.text});
  factory MemberQuizChoice.fromJson(Map<String, dynamic> json) =>
      MemberQuizChoice(
        index: (json['index'] as num?)?.toInt() ?? 0,
        text: json['text'] as String? ?? '',
      );
}

class MemberQuizResult {
  final int score;
  final bool passed;
  final int correctAnswers;
  final int totalQuestions;

  const MemberQuizResult({
    required this.score,
    required this.passed,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  factory MemberQuizResult.fromJson(Map<String, dynamic> json) =>
      MemberQuizResult(
        score: (json['score'] as num?)?.toInt() ?? 0,
        passed: json['passed'] == true,
        correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
        totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      );
}
