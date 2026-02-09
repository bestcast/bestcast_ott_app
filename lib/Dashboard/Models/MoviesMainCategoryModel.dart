import 'Movie.dart';

class MoviesMainCategoryModel {
  String? id;
  String? title;
  List<Movies>? movies;

  MoviesMainCategoryModel({
    required this.id,
    required this.title,
    required this.movies,
  });

  factory MoviesMainCategoryModel.fromJson(Map<String, dynamic> json) =>
      MoviesMainCategoryModel(
        id: json["id"].toString(),
        title: json["title"].toString(),
        movies:
            List<Movies>.from(json["movies"].map((x) => Movies.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "movies": List<dynamic>.from(movies!.map((x) => x.toJson())),
      };
}
