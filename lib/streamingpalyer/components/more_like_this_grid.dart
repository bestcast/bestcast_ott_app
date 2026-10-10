import 'package:flutter/material.dart';
import '../models/related_movie_modelss.dart';
import '../../common_files/shimmer/app_shimmer_image.dart';

class MoreLikeThisGrid extends StatelessWidget {
  final List<RelatedMovieData> relatedMovieData;
  final Function(String) onMovieTap;

  const MoreLikeThisGrid({
    super.key,
    required this.relatedMovieData,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    if (relatedMovieData.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
        child: Center(
          child: Text(
            "More recommendations coming soon",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: relatedMovieData.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2 / 3, // Standard movie portrait ratio
        ),
        itemBuilder: (context, index) {
          final item = relatedMovieData[index];
          final String posterUrl = item.movie?.portraitsmall ?? item.movie?.portrait ?? item.movie?.thumbnail ?? '';
          final String movieId = item.movie?.id?.toString() ?? '';

          return GestureDetector(
            onTap: () {
              if (movieId.isNotEmpty) {
                onMovieTap(movieId);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AppShimmerImage(
                  imageUrl: posterUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 8,
                  errorAsset: 'images/sample_movie_1.jpg',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
