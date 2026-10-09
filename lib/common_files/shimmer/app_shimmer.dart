import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Premium dark-mode Shimmer wrapper calibrated for BestCast OTT
class AppShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;
  final ShimmerDirection direction;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1400),
    this.direction = ShimmerDirection.ltr,
  });

  // Dark metallic tones that blend seamlessly with OLED blacks (#000000) & dark card surfaces (#1A1A1A)
  static const Color defaultBaseColor = Color(0xFF1E1E22);
  static const Color defaultHighlightColor = Color(0xFF333338);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? defaultBaseColor,
      highlightColor: highlightColor ?? defaultHighlightColor,
      period: period,
      direction: direction,
      child: child,
    );
  }
}

/// A versatile rounded shimmer box / container
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.margin,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AppShimmer.defaultBaseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
      ),
    );
  }
}

/// Circular shimmer placeholder for avatars, icons, and action circles
class ShimmerCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const ShimmerCircle({
    super.key,
    required this.size,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: const BoxDecoration(
        color: AppShimmer.defaultBaseColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Shimmer placeholder bar representing lines of text
class ShimmerText extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerText({
    super.key,
    required this.width,
    this.height = 14.0,
    this.borderRadius = 4.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AppShimmer.defaultBaseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer placeholder card representing portrait movie / series poster cards
class ShimmerPosterCard extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool showTitleBar;
  final EdgeInsetsGeometry? margin;

  const ShimmerPosterCard({
    super.key,
    this.width = 124.0,
    this.height = 165.0,
    this.borderRadius = 8.0,
    this.showTitleBar = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 5.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ShimmerBox(
            width: width,
            height: height,
            borderRadius: borderRadius,
          ),
          if (showTitleBar) ...[
            const SizedBox(height: 6),
            ShimmerText(width: width * 0.75, height: 11),
          ],
        ],
      ),
    );
  }
}
