class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex; // Optional, for future use

  const QuizQuestion({
    required this.question,
    required this.options,
    this.correctIndex = 0,
  });
}

class QuizData {
  static const List<QuizQuestion> questions = [
    QuizQuestion(
      question: "What is the name of the main character?",
      options: ["John", "Mike", "Sarah", "David"],
    ),
    QuizQuestion(
      question: "Which city is shown in the opening scene?",
      options: ["New York", "London", "Paris", "Tokyo"],
    ),
    QuizQuestion(
      question: "What color was the car?",
      options: ["Red", "Blue", "Black", "White"],
    ),
    QuizQuestion(
      question: "Who is the villain?",
      options: ["The Joker", "Lex Luthor", "Thanos", "Voldemort"],
    ),
    QuizQuestion(
      question: "What year did the movie release?",
      options: ["2020", "2021", "2022", "2023"],
    ),
    QuizQuestion(
      question: "What is the lead actor's name?",
      options: ["Tom Cruise", "Brad Pitt", "Leonardo DiCaprio", "Johnny Depp"],
    ),
    QuizQuestion(
      question: "Which genre is this movie?",
      options: ["Action", "Comedy", "Drama", "Sci-Fi"],
    ),
    QuizQuestion(
      question: "Who directed this movie?",
      options: ["Steven Spielberg", "Christopher Nolan", "James Cameron", "Quentin Tarantino"],
    ),
    QuizQuestion(
      question: "What is the rating of this movie?",
      options: ["PG-13", "R", "G", "NC-17"],
    ),
  ];
}
