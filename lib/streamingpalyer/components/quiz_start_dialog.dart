import 'package:bestcaststudios/common_files/app_default_colors.dart';
import 'package:flutter/material.dart';

class QuizStartDialog extends StatefulWidget {
  final Function(bool) onSelection;

  const QuizStartDialog({super.key, required this.onSelection});

  @override
  State<QuizStartDialog> createState() => _QuizStartDialogState();
}

class _QuizStartDialogState extends State<QuizStartDialog> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: AppDefaultColors.appColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Quiz Time!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "NOTE: Once Start to play do not Forward or Rewind the movie. Your quiz appears anytime.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value!;
                    });
                  },
                ),
                Text(
                  "Accept Terms & Conditions",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => widget.onSelection(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("SKIP", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => widget.onSelection(true) || isChecked == true,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("PLAY", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
