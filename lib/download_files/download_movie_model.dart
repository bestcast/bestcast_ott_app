// Dart imports:
import 'dart:convert';

DownloadedMovieModel moviesModelFromJson(String str) =>
    DownloadedMovieModel.fromJson(json.decode(str));

String moviesModelToJson(DownloadedMovieModel data) =>
    json.encode(data.toJson());

class DownloadedMovieModel {
  String? movieID;
  String? title;
  String? description;
  String? movieName;
  String? thumnail;
  String? moviePath;

  DownloadedMovieModel(
      {this.movieID,
      this.title,
      this.description,
      this.movieName,
      this.thumnail,
      this.moviePath});

  DownloadedMovieModel.fromJson(Map<String, dynamic> json) {
    movieID = json['movieID'];
    title = json['title'];
    description = json['description'];
    movieName = json['movieName'];
    thumnail = json['thumnail'];
    moviePath = json['moviePath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['movieID'] = movieID;
    data['title'] = title;
    data['description'] = description;
    data['movieName'] = movieName;
    data['thumnail'] = thumnail;
    data['moviePath'] = moviePath;
    return data;
  }
}
