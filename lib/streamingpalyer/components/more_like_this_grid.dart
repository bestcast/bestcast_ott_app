import 'package:flutter/material.dart';
import '../models/related_movie_modelss.dart'; // Check import path
import '../../common_files/movie_vertical_card_background.dart';

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
    return Container(
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 0,
        crossAxisSpacing: 1,
        crossAxisCount: 3,
        childAspectRatio: 3 / 4.2,
        children: List.generate(relatedMovieData.length, (index) {
          return _buildItemCard(relatedMovieData[index]);
        }),
      ),
    );
  }

  Widget _buildItemCard(RelatedMovieData relatedMovieData) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            onMovieTap(relatedMovieData.movie!.id.toString());
          },
          child: MovieVerticalCardBackgroundView(
            Container(
              child: SizedBox(
                width: 130,
                height: 170,
                child: FadeInImage(
                  placeholder: AssetImage("images/sample_movie_1.jpg"),
                  image: NetworkImage(
                      relatedMovieData.movie!.portraitsmall.toString()),
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset('images/sample_movie_1.jpg');
                  },
                  width: 130,
                  height: 170,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
