import 'package:flutter/material.dart';

class QuizStartDialog extends StatefulWidget {
  final Function(bool, String) onSelection;

  const QuizStartDialog({super.key, required this.onSelection});

  @override
  State<QuizStartDialog> createState() => _QuizStartDialogState();
}

class _QuizStartDialogState extends State<QuizStartDialog> {
  bool isChecked = false;
  String selectedLanguage = 'english';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF031634),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Quiz Time!",
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "NOTE: Once Start to play do not Forward or Rewind the movie. Your quiz appears anytime.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Select Language: ",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A2540),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blueAccent, width: 1.5),
                        ),
                        child: DropdownButton<String>(
                          value: selectedLanguage,
                          dropdownColor: const Color(0xFF031634),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.amberAccent),
                          underline: const SizedBox(),
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                          items: const [
                            DropdownMenuItem(
                              value: 'english',
                              child: Text('English'),
                            ),
                            DropdownMenuItem(
                              value: 'tamil',
                              child: Text('Tamil'),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedLanguage = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: Colors.white70,
                        ),
                        child: Checkbox(
                          value: isChecked,
                          activeColor: Colors.blueAccent,
                          checkColor: Colors.white,
                          onChanged: (value) {
                            setState(() {
                              isChecked = value ?? false;
                            });
                          },
                        ),
                      ),
                      const Flexible(
                        child: Text(
                          "Accept Terms & Conditions",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => widget.onSelection(false, selectedLanguage),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(color: Colors.redAccent, width: 2),
                            ),
                            elevation: 10,
                          ),
                          child: const Text(
                            "SKIP",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isChecked ? () => widget.onSelection(true, selectedLanguage) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                            disabledBackgroundColor: Colors.grey.withValues(alpha: 0.1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(
                                color: isChecked ? Colors.blueAccent : Colors.grey,
                                width: 2,
                              ),
                            ),
                            elevation: 10,
                          ),
                          child: Text(
                            "PLAY",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isChecked ? Colors.white : Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
