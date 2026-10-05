import 'package:flutter/material.dart';
import 'package:bestcaststudios/common_files/app_default_colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(strokeWidth: 5, color: AppDefaultColors.primaryRed),
    );
  }
}
