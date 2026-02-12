import 'dart:async';
import 'package:bestcaststudios/streamingpalyer/models/quiz_data.dart';
import 'package:flutter/material.dart';

class QuizOverlay extends StatefulWidget {
  final QuizQuestion question;
  final int questionIndex;
  final int totalQuestions;
  final VoidCallback onComplete;
  final int durationSeconds;

  const QuizOverlay({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.onComplete,
    this.durationSeconds = 10,
  });

  @override
  State<QuizOverlay> createState() => _QuizOverlayState();
}

class _QuizOverlayState extends State<QuizOverlay> {
  late int _timeLeft;
  Timer? _timer;
  int? _selectedOptionIndex;

  final List<String> optionPrefixes = ["A", "B", "C", "D"];

  @override
  void initState() {
    super.initState();
    _startTimer();
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

  void _submitAnswer() {
    _timer?.cancel();

    // TODO: Send selected answer to backend
    // ApiServices.submitAnswer(widget.question.id, _selectedOptionIndex);

    widget.onComplete();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
                        onTap: () {
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
                                  widget.question.options[index],
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
                      onPressed: _selectedOptionIndex == null ? null : _submitAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
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
