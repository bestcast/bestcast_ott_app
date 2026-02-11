class QuizResponse {
  final String status;
  final int total;
  final List<QuizQuestion> questions;

  QuizResponse({
    required this.status,
    required this.total,
    required this.questions,
  });

  factory QuizResponse.fromJson(Map<String, dynamic> json) {
    var list = json['questions'] as List;
    List<QuizQuestion> questionsList = list.map((i) => QuizQuestion.fromJson(i)).toList();

    return QuizResponse(
      status: json['status'] ?? '',
      total: json['total'] ?? 0,
      questions: questionsList,
    );
  }
}

class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int popupTime;
  final int showQuestionTime;
  // We can store full options if needed later, but for UI we need List<String>

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.popupTime,
    required this.showQuestionTime,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List;
    // Map option 'name' to the string list for UI
    List<String> optionsStrings = optionsList.map((i) => i['name'].toString()).toList();

    return QuizQuestion(
      id: int.tryParse(json['id'].toString()) ?? 0,
      question: json['question'] ?? '',
      options: optionsStrings,
      popupTime: int.tryParse(json['popup_time'].toString()) ?? 0,
      showQuestionTime: int.tryParse(json['show_question_time'].toString()) ?? 10,
    );
  }
}

class QuizData {
  // Static fallback data (Optional: Can keep or remove. Keeping for safety/fallback)
  static const List<QuizQuestion> questions = [
    QuizQuestion(id: 0, question: "What is the name of the main character?", options: ["John", "Mike", "Sarah", "David"], popupTime: 10, showQuestionTime: 10),
    // ... we can reduce this list or remove it if we strictly rely on API
  ];
}
