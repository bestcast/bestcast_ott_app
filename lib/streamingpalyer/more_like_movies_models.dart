import 'dart:convert';

MoreLikeMoviesModel moreMoviesModelFromJson(String str) => MoreLikeMoviesModel.fromJson(json.decode(str));

String moreMoviesModelToJson(MoreLikeMoviesModel data) => json.encode(data.toJson());

class MoreLikeMoviesModel {
  String? movieID;
  String? movieName;
  String? thumnailPicture;

  MoreLikeMoviesModel({this.movieID, this.movieName, this.thumnailPicture});

  factory MoreLikeMoviesModel.fromJson(Map<String, dynamic> json) => MoreLikeMoviesModel(movieID: json["movieID"] ?? "", movieName: json["movieName"] ?? "", thumnailPicture: json["thumnailPicture"] ?? "");

  Map<String, dynamic> toJson() => {"movieID": movieID, "movieName": movieName, "thumnailPicture": thumnailPicture};
}
