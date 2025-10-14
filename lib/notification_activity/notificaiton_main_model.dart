// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:bestcaststudios/Dashboard/Models/Movie.dart';

NoficationMainModel noficationMainModelFromJson(String str) =>
    NoficationMainModel.fromJson(json.decode(str));

String noficationMainModelToJson(NoficationMainModel data) =>
    json.encode(data.toJson());

class NoficationMainModel {
  String? id;
  String? isRead;
  String? title;
  String? thumbnail;
  String? createdAt;
  String? createdText;
  Movies? movie;

  NoficationMainModel({
    required this.id,
    required this.isRead,
    required this.title,
    required this.thumbnail,
    required this.createdAt,
    required this.createdText,
    required this.movie,
  });

  factory NoficationMainModel.fromJson(Map<String, dynamic> json) =>
      NoficationMainModel(
        id: json["id"].toString(),
        isRead: json["is_read"].toString(),
        title: json["title"].toString(),
        thumbnail: json["thumbnail"].toString(),
        createdAt: json["created_at"].toString(),
        createdText: json["created_text"].toString(),
        movie: Movies.fromJson(json["movie"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "is_read": isRead,
        "title": title,
        "thumbnail": thumbnail,
        "created_at": createdAt.toString(),
        "created_text": createdText,
        "movie": movie?.toJson(),
      };
}
