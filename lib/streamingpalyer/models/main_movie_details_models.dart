import 'dart:convert';

MainVideoDetailsModel mainVideoDetailsModelFromJson(String str) =>
    MainVideoDetailsModel.fromJson(json.decode(str));

String mainVideoDetailsModelToJson(MainVideoDetailsModel data) =>
    json.encode(data.toJson());

class MainVideoDetailsModel {
  MovieData data;

  MainVideoDetailsModel({
    required this.data,
  });

  factory MainVideoDetailsModel.fromJson(Map<String, dynamic> json) =>
      MainVideoDetailsModel(
        data: MovieData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
      };
}

class MovieData {
  String id;
  String urlkey;
  String title;
  String movie_access;
  String content;
  String publishedDate;
  String releaseDate;
  String image;
  String medium;
  String thumbnail;
  String portraitsmall;
  String portrait;
  String duration;
  String durationText;
  String certificate;
  String certificateText;
  String tagText;
  String topten;
  String trailer;
  String trailer480P;
  String videoUrl;
  String moviesource;
  String subtitleStatus;

  MovieData({
    required this.id,
    required this.urlkey,
    required this.title,
    required this.movie_access,
    required this.content,
    required this.publishedDate,
    required this.releaseDate,
    required this.image,
    required this.medium,
    required this.thumbnail,
    required this.portraitsmall,
    required this.portrait,
    required this.duration,
    required this.durationText,
    required this.certificate,
    required this.certificateText,
    required this.tagText,
    required this.topten,
    required this.trailer,
    required this.trailer480P,
    required this.videoUrl,
    required this.moviesource,
    required this.subtitleStatus,
  });

  factory MovieData.fromJson(Map<String, dynamic> json) => MovieData(
        id: json["id"],
        urlkey: json["urlkey"],
        title: json["title"],
        movie_access: json["movie_access"],
        content: json["content"],
        publishedDate: json["published_date"],
        releaseDate: json["release_date"],
        image: json["image"],
        medium: json["medium"],
        thumbnail: json["thumbnail"],
        portraitsmall: json["portraitsmall"],
        portrait: json["portrait"],
        duration: json["duration"],
        durationText: json["duration_text"],
        certificate: json["certificate"],
        certificateText: json["certificate_text"],
        tagText: json["tag_text"],
        topten: json["topten"],
        trailer: json["trailer"],
        trailer480P: json["trailer_480p"],
        videoUrl: json["video_url"],
        moviesource: json["moviesource"],
        subtitleStatus: json["subtitle_status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "urlkey": urlkey,
        "title": title,
        "movie_access": movie_access,
        "content": content,
        "published_date": publishedDate,
        "release_date": releaseDate,
        "image": image,
        "medium": medium,
        "thumbnail": thumbnail,
        "portraitsmall": portraitsmall,
        "portrait": portrait,
        "duration": duration,
        "duration_text": durationText,
        "certificate": certificate,
        "certificate_text": certificateText,
        "tag_text": tagText,
        "topten": topten,
        "trailer": trailer,
        "trailer_480p": trailer480P,
        "video_url": videoUrl,
        "moviesource": moviesource,
        "subtitle_status": subtitleStatus,
      };
}
