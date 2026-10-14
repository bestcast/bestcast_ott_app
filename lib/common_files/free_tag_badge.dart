import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_default_colors.dart';

enum FreeTagStyle {
  /// Sleek, modern OTT pill badge (e.g. Netflix, Prime Video style)
  pill,

  /// Crisp diagonal corner ribbon folded over the corner
  ribbon,
}

/// A premium, reusable badge indicating free-to-watch content for movies and webseries.
class FreeTagBadge extends StatelessWidget {
  final FreeTagStyle style;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final String text;

  const FreeTagBadge({
    super.key,
    this.style = FreeTagStyle.pill,
    this.fontSize = 9.0,
    this.padding,
    this.borderRadius = 4.0,
    this.text = 'FREE',
  });

  /// Factory for detail screens metadata chips row (e.g. next to Year, HD, Certificate).
  const FreeTagBadge.chip({
    super.key,
    this.style = FreeTagStyle.pill,
    this.fontSize = 10.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5),
    this.borderRadius = 4.0,
    this.text = 'FREE',
  });

  /// Factory for corner ribbon presentation.
  const FreeTagBadge.ribbon({
    super.key,
    this.fontSize = 8.5,
    this.borderRadius = 0.0,
    this.text = 'FREE',
  })  : style = FreeTagStyle.ribbon,
        padding = EdgeInsets.zero;

  /// Convenience positioned helper for poster cards.
  static Widget positioned({
    Key? key,
    double? top = 5.0,
    double? right = 5.0,
    double? left,
    double? bottom,
    FreeTagStyle style = FreeTagStyle.pill,
    double fontSize = 9.0,
    EdgeInsetsGeometry? padding,
  }) {
    if (style == FreeTagStyle.ribbon) {
      return Positioned(
        top: 0,
        right: 0,
        child: FreeTagBadge.ribbon(key: key, fontSize: fontSize),
      );
    }
    return Positioned(
      top: top,
      right: right,
      left: left,
      bottom: bottom,
      child: FreeTagBadge(
        key: key,
        style: style,
        fontSize: fontSize,
        padding: padding,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (style == FreeTagStyle.ribbon) {
      return _buildCornerRibbon();
    }
    return _buildPillBadge();
  }

  Widget _buildPillBadge() {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF1E27),
            Color(0xFFB80007),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildCornerRibbon() {
    return CustomPaint(
      size: const Size(42, 42),
      painter: _CornerRibbonPainter(
        ribbonColor: AppDefaultColors.primaryRed,
        text: text,
        fontSize: fontSize,
      ),
    );
  }
}

class _CornerRibbonPainter extends CustomPainter {
  final Color ribbonColor;
  final String text;
  final double fontSize;

  _CornerRibbonPainter({
    required this.ribbonColor,
    required this.text,
    required this.fontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ribbonColor
      ..style = PaintingStyle.fill;

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final path = Path()
      ..moveTo(size.width * 0.25, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.75)
      ..close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // Diagonal highlight stroke
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawLine(
      Offset(size.width * 0.25, 0),
      Offset(size.width, size.height * 0.75),
      borderPaint,
    );

    // Text rotated 45 degrees
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.6,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(size.width * 0.68, size.height * 0.32);
    canvas.rotate(math.pi / 4);
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CornerRibbonPainter oldDelegate) {
    return oldDelegate.ribbonColor != ribbonColor ||
        oldDelegate.text != text ||
        oldDelegate.fontSize != fontSize;
  }
}
