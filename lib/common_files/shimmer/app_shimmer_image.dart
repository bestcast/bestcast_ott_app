import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'app_shimmer.dart';

/// Reusable network image with built-in Shimmer loading placeholder and error fallback
class AppShimmerImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final String errorAsset;

  final int? memCacheWidth;
  final int? memCacheHeight;

  const AppShimmerImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.memCacheWidth,
    this.memCacheHeight,
    this.fit = BoxFit.cover,
    this.borderRadius = 0.0,
    this.errorAsset = 'images/default_portrate_small.jpg',
  });

  @override
  Widget build(BuildContext context) {
    final String trimmedUrl = imageUrl.trim();
    final bool isValidUrl = trimmedUrl.isNotEmpty &&
        (trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://'));

    Widget content;
    if (!isValidUrl) {
      content = Image.asset(
        errorAsset,
        width: width,
        height: height,
        fit: fit,
      );
    } else {
      content = CachedNetworkImage(
        imageUrl: trimmedUrl,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        fadeInDuration: const Duration(milliseconds: 180),
        fadeOutDuration: const Duration(milliseconds: 100),
        placeholder: (context, url) => AppShimmer(
          child: ShimmerBox(
            width: width,
            height: height,
            borderRadius: borderRadius,
          ),
        ),
        errorWidget: (context, url, error) => Image.asset(
          errorAsset,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return content;
  }
}
