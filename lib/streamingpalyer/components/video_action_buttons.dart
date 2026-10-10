import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common_files/app_default_colors.dart';

class VideoActionButtons extends StatelessWidget {
  final bool isRated;
  final bool isLike;
  final bool isDisLike;
  final VoidCallback onRate;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onShare;

  const VideoActionButtons({
    super.key,
    required this.isRated,
    required this.isLike,
    required this.isDisLike,
    required this.onRate,
    required this.onLike,
    required this.onDislike,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildActionButton(
            icon: isRated ? Icons.check_rounded : Icons.add_rounded,
            label: 'My List',
            isActive: isRated,
            activeColor: const Color(0xFF4ADE80), // Subtle emerald green for added
            onTap: () {
              HapticFeedback.lightImpact();
              onRate();
            },
          ),
          _buildActionButton(
            icon: isLike ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
            label: 'I love this',
            isActive: isLike,
            activeColor: AppDefaultColors.thikRed,
            onTap: () {
              HapticFeedback.lightImpact();
              onLike();
            },
          ),
          _buildActionButton(
            icon: isDisLike ? Icons.thumb_down_rounded : Icons.thumb_down_outlined,
            label: 'Not for me',
            isActive: isDisLike,
            activeColor: Colors.white,
            onTap: () {
              HapticFeedback.lightImpact();
              onDislike();
            },
          ),
          _buildActionButton(
            icon: Icons.share_rounded,
            label: 'Share',
            isActive: false,
            onTap: () {
              HapticFeedback.lightImpact();
              onShare();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Color? activeColor,
  }) {
    final effectiveColor = isActive ? (activeColor ?? Colors.white) : Colors.white.withValues(alpha: 0.85);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isActive
                        ? (activeColor ?? Colors.white).withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? (activeColor ?? Colors.white).withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.12),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: effectiveColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? Colors.white : AppDefaultColors.textLightGray,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
