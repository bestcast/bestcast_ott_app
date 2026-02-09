import 'dart:convert';

MoviesModel moviesModelFromJson(String str) =>
    MoviesModel.fromJson(json.decode(str));

String moviesModelToJson(MoviesModel data) => json.encode(data.toJson());

class MoviesModel {
  String? catogoryID;
  String? movieID;
  String? thumbnailPicture;
  String? lastPlayedTime;
  String? title;
  String? descriptions;

  MoviesModel(
      {this.catogoryID,
      this.movieID,
      this.thumbnailPicture,
      this.lastPlayedTime,
      this.title,
      this.descriptions});

  factory MoviesModel.fromJson(Map<String, dynamic> json) => MoviesModel(
        catogoryID: json["catogoryID"] ?? "",
        movieID: json["movieID"] ?? "",
        thumbnailPicture: json["thumbnailPicture"] ?? "",
        lastPlayedTime: json["lastPlayedTime"] ?? "",
        title: json["title"] ?? "",
        descriptions: json["descriptions"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "catogoryID": catogoryID,
        "movieID": movieID,
        "thumbnailPicture": thumbnailPicture,
        "lastPlayedTime": lastPlayedTime,
        "title": title,
        "descriptions": descriptions
      };
}
