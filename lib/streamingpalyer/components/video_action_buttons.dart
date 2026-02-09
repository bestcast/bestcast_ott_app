import 'package:flutter/material.dart';
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
    return Container(
      padding: const EdgeInsets.only(bottom: 15, top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildActionButton(
            icon: isRated ? Icons.check : Icons.add,
            label: 'My List',
            onTap: onRate,
            iconSize: 40,
          ),
          _buildActionButton(
            icon: isLike
                ? Icons.thumb_up_off_alt_rounded
                : Icons.thumb_up_off_alt_outlined,
            label: 'I love this',
            onTap: onLike,
            iconSize: 25,
            fontSize: 12,
          ),
          _buildActionButton(
            icon: isDisLike
                ? Icons.thumb_down_alt
                : Icons.thumb_down_off_alt_outlined,
            label: 'Not for me',
            onTap: onDislike,
            iconSize: 25,
            fontSize: 12,
          ),
          _buildActionButton(
            icon: Icons.share,
            label: 'Share',
            onTap: onShare,
            iconSize: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    double iconSize = 25,
    double fontSize =
        14, // Default font size if not specified, though used 12 in some
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: Colors.white,
            size: iconSize,
          ),
          onPressed: onTap,
        ),
        Padding(
          padding: EdgeInsets.only(left: 10), // Kept from original
          child: Text(
            label,
            style: TextStyle(
              fontSize:
                  fontSize == 14 && (label == 'My List' || label == 'Share')
                      ? null
                      : fontSize, // Keep original styling logic
              color: AppDefaultColors.textLightGray,
            ),
          ),
        ),
      ],
    );
  }
}
