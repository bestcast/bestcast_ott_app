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

  const QuizOverlay({super.key, required this.question, required this.questionIndex, required this.totalQuestions, required this.onComplete, required this.userId, required this.movieId, required this.attemptId, required this.token, this.durationSeconds = 10});

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

    // Handle case where time runs out and no option is selected
    String? optionId;
    if (_selectedOptionIndex != null) {
      optionId = widget.question.options[_selectedOptionIndex!].id.toString();
    }

    await submitQuizData({
      "question_id": widget.question.id,
      "option_id": optionId,
      "answered_seconds": widget.durationSeconds - _timeLeft, // Calculate time taken
    });

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
      widget.onComplete();
    }
  }

  Future<void> submitQuizData(Map<String, dynamic> answer) async {
    final postValues = {'user_id': widget.userId, 'movie_id': widget.movieId, 'attempt_id': widget.attemptId, 'answer': answer};

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

  Widget _buildOption(int displayIndex, QuizOption option) {
    final isSelected = _selectedOptionIndex == displayIndex;
    final Color accentColor = isSelected ? Colors.amberAccent : Colors.white;
    final Color borderColor = isSelected ? Colors.amberAccent : Colors.blueAccent;

    return InkWell(
      onTap: _isSubmitting
          ? null
          : () {
              setState(() {
                _selectedOptionIndex = displayIndex;
              });
            },
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(color: const Color(0xFF031634), borderRadius: BorderRadius.circular(40), border: Border.all(color: borderColor, width: 2), boxShadow: [
          BoxShadow(color: borderColor.withValues(alpha: isSelected ? 0.6 : 0.3), blurRadius: 10),
        ]),
        child: Row(
          children: [
            /// Prefix Letter
            Text(
              optionPrefixes[displayIndex],
              style: TextStyle(
                color: accentColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),

            /// Option Text
            Expanded(
              child: Text(
                option.name,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTwoColumns = screenWidth > 500;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: const Color(0xFF020C1F).withValues(alpha: 0.85),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              /// Header with Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration:
                        BoxDecoration(color: _timeLeft <= 3 ? Colors.redAccent.withValues(alpha: 0.2) : Colors.blueAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: _timeLeft <= 3 ? Colors.redAccent : Colors.blueAccent, width: 1.5), boxShadow: [
                      BoxShadow(
                        color: (_timeLeft <= 3 ? Colors.redAccent : Colors.blueAccent).withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]),
                    child: Text(
                      "00:${_timeLeft.toString().padLeft(2, '0')}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              /// Question Box
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF031634),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 1),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.question.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              /// Options Grid
              Expanded(
                flex: 5,
                child: isTwoColumns && widget.question.options.length == 4
                    ? Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(child: _buildOption(0, widget.question.options[0])),
                                const SizedBox(width: 16),
                                Expanded(child: _buildOption(2, widget.question.options[2])),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(child: _buildOption(1, widget.question.options[1])),
                                const SizedBox(width: 16),
                                Expanded(child: _buildOption(3, widget.question.options[3])),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: List.generate(
                          widget.question.options.length,
                          (index) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: _buildOption(index, widget.question.options[index]),
                            ),
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              /// Submit Button
              SizedBox(
                width: 300,
                height: 48,
                child: ElevatedButton(
                  onPressed: (_selectedOptionIndex == null || _isSubmitting) ? null : _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                    disabledBackgroundColor: Colors.grey.withValues(alpha: 0.1),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: (_selectedOptionIndex != null) ? Colors.blueAccent : Colors.grey,
                        width: 2,
                      ),
                    ),
                    elevation: 10,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent))
                      : Text(
                          "Submit",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: (_selectedOptionIndex != null) ? Colors.white : Colors.grey,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
