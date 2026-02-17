import 'dart:async';
import 'dart:convert';
import 'package:bestcaststudios/app_config/appconfig.dart';
import 'package:bestcaststudios/common_files/api_services.dart';
import 'package:bestcaststudios/streamingpalyer/models/quiz_data.dart';
import 'package:flutter/material.dart';

class QuizOverlay extends StatefulWidget {
  final QuizQuestion question;
  final int questionIndex;
  final int totalQuestions;
  final VoidCallback onComplete;
  final int durationSeconds;
  final String userId;
  final String movieId;
  final String attemptId;
  final String token;

  const QuizOverlay({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.onComplete,
    required this.userId,
    required this.movieId,
    required this.attemptId,
    required this.token,
    this.durationSeconds = 10,
  });

  @override
  State<QuizOverlay> createState() => _QuizOverlayState();
}

class _QuizOverlayState extends State<QuizOverlay> {
  late int _timeLeft;
  Timer? _timer;
  bool _isSubmitting = false;
  int? _selectedOptionIndex;
  final List<String> optionPrefixes = ["A", "B", "C", "D"];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timeLeft = widget.durationSeconds;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _submitAnswer(); // Auto submit when time ends
      }
    });
  }

  Future<void> _submitAnswer() async {
    if (_isSubmitting) return;

    _timer?.cancel();

    setState(() {
      _isSubmitting = true;
    });

    await submitQuizData(
      {
        "question_id": widget.question.id,
        "option_id": widget.question.options[_selectedOptionIndex!].id,
        "answered_seconds": widget.durationSeconds - _timeLeft, // Calculate time taken
      },
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
      widget.onComplete();
    }
  }

  Future<void> submitQuizData(Map<String, dynamic> answer) async {
    final postValues = {
      'user_id': widget.userId,
      'movie_id': widget.movieId,
      'attempt_id': widget.attemptId,
      'answer': answer,
    };

    debugPrint("Submitting Quiz Answer: XXX $postValues");

    try {
      final response = await ApiServices().postRequestToken(AppConfig.submitQuiz, postValues, widget.token);

      if (response.statusCode != 200) {
        debugPrint("Quiz API Error: AAA ${response.statusCode} - ${response.body}");
        return;
      }
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true || jsonResponse['status'] == 'success') {
        debugPrint("Quiz Answer Submitted Successfully YYY");
      } else {
        debugPrint("Server message: BBB ${jsonResponse['message']}");
      }
    } catch (e) {
      debugPrint("Quiz Submit Error: CCC $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.black.withOpacity(0.7),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Question ${widget.questionIndex + 1}/${widget.totalQuestions}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _timeLeft <= 3 ? Colors.redAccent : Colors.blueAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "00:${_timeLeft.toString().padLeft(2, '0')}",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// Question
                  Text(
                    widget.question.question,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// Options with A, B, C, D
                  ...List.generate(widget.question.options.length, (index) {
                    final isSelected = _selectedOptionIndex == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        onTap: _isSubmitting
                            ? null
                            : () {
                                setState(() {
                                  _selectedOptionIndex = index;
                                });
                              },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.blueAccent : Colors.white12,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              /// Prefix Circle (A, B, C, D)
                              Container(
                                width: 34,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? Colors.blueAccent : Colors.white24,
                                ),
                                child: Text(
                                  optionPrefixes[index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              /// Option Text
                              Expanded(
                                child: Text(
                                  widget.question.options[index].name,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 30),

                  /// Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_selectedOptionIndex == null || _isSubmitting) ? null : _submitAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        disabledBackgroundColor: Colors.blueAccent.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Submit Answer",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
