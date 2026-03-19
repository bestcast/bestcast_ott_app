class QuizResponse {
  final String status;
  final int total;
  final String attemptId;
  final List<QuizQuestion> questions;

  QuizResponse({
    required this.status,
    required this.total,
    required this.attemptId,
    required this.questions,
  });

  factory QuizResponse.fromJson(Map<String, dynamic> json) {
    var list = json['questions'] as List;
    List<QuizQuestion> questionsList = list.map((i) => QuizQuestion.fromJson(i)).toList();

    return QuizResponse(
      status: json['status'] ?? '',
      total: json['total'] ?? 0,
      attemptId: (json['quiz_attempt_id'] ?? json['attempt_id'])?.toString() ?? '',
      questions: questionsList,
    );
  }
}

class QuizOption {
  final int id;
  final int questionId;
  final String name;
  final bool isCorrect;

  QuizOption({
    required this.id,
    required this.questionId,
    required this.name,
    required this.isCorrect,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: int.tryParse(json['id'].toString()) ?? 0,
      questionId: int.tryParse(json['question_id'].toString()) ?? 0,
      name: json['name'] ?? '',
      isCorrect: json['is_correct'] == 1 || json['is_correct'] == true,
    );
  }
}

class QuizQuestion {
  final int id;
  final String question;
  final List<QuizOption> options;
  final int popupTime;
  final int showQuestionTime;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.popupTime,
    required this.showQuestionTime,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List;
    List<QuizOption> optionsObjs = optionsList.map((i) => QuizOption.fromJson(i)).toList();

    return QuizQuestion(
      id: int.tryParse(json['id'].toString()) ?? 0,
      question: json['question'] ?? '',
      options: optionsObjs,
      popupTime: int.tryParse(json['popup_time'].toString()) ?? 0,
      showQuestionTime: int.tryParse(json['show_question_time'].toString()) ?? 10,
    );
  }
}

class QuizData {
  // Static fallback data
  static final List<QuizQuestion> questions = [
    QuizQuestion(
      id: 0,
      question: "What is the name of the main character?",
      options: [
        QuizOption(id: 1, questionId: 0, name: "John", isCorrect: false),
        QuizOption(id: 2, questionId: 0, name: "Mike", isCorrect: true),
        QuizOption(id: 3, questionId: 0, name: "Sarah", isCorrect: false),
        QuizOption(id: 4, questionId: 0, name: "David", isCorrect: false),
      ],
      popupTime: 10,
      showQuestionTime: 10,
    ),
  ];
}
