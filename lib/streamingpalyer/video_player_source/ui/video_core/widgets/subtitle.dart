import 'package:flutter/material.dart';

import 'package:bestcaststudios/streamingpalyer/video_player_source/data/repositories/video.dart';

class VideoCoreActiveSubtitleText extends StatelessWidget {
  const VideoCoreActiveSubtitleText({super.key});

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final style = query.videoStyle(context).subtitleStyle;
    final subtitle = query.video(context, listen: true).activeCaptionData;

    if (subtitle == null || subtitle.text.isEmpty) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;
    final double baseDimension = size.width < size.height ? size.width : size.height;

    // Responsive font size calculation (base 16 on 375dp viewport)
    final double responsiveFontSize = (baseDimension / 375.0) * 16.0;
    final double finalFontSize = responsiveFontSize.clamp(12.0, 22.0);

    // Responsive padding scale calculation
    final double paddingScale = (baseDimension / 375.0).clamp(0.5, 1.2);
    final resolvedPadding = style.padding.resolve(Directionality.of(context));
    final responsivePadding = EdgeInsets.only(
      left: resolvedPadding.left * paddingScale,
      right: resolvedPadding.right * paddingScale,
      top: resolvedPadding.top * paddingScale,
      bottom: resolvedPadding.bottom * paddingScale,
    );

    // Merge styles and remove standard inline background
    final responsiveTextStyle = style.style.copyWith(
      fontSize: finalFontSize,
      backgroundColor: Colors.transparent,
      decoration: TextDecoration.none,
    );

    return Align(
      alignment: style.alignment,
      child: Padding(
        padding: responsivePadding,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Text(
            subtitle.text,
            style: responsiveTextStyle,
            textAlign: style.textAlign,
          ),
        ),  
      ),
    );
  }
}
