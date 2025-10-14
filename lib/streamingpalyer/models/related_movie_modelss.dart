// Project imports:
import 'package:bestcaststudios/Dashboard/Models/Movie.dart';

class RelatedMovieData {
  Movies? movie;

  RelatedMovieData({
    required this.movie,
  });

  factory RelatedMovieData.fromJson(Map<String, dynamic> json) =>
      RelatedMovieData(
        movie: Movies.fromJson(json["movie"]),
      );

  Map<String, dynamic> toJson() => {
        "movie": movie?.toJson(),
      };
}
