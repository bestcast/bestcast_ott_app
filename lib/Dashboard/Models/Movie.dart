import 'dart:convert';

import 'package:bestcaststudios/Dashboard/Models/Usermovies.dart';
import 'package:bestcaststudios/Webseries/Models/webseries_models.dart';

Movies moviesFromJson(String str) => Movies.fromJson(json.decode(str));

String moviesToJson(Movies data) => json.encode(data.toJson());

class Movies {
  String? id;
  String? title;
  String? movie_access;
  String? topten;
  String? trailer;
  String? certificate;
  String? duration;
  String? tagText;
  String? publishedDate;
  String? userlist;
  String? userlike;
  String? thumbnail;
  String? portraitsmall;
  String? portrait;
  Usermovies? usermovies;
  String? content;
  String? image;
  String? medium;
  bool? isWebseries;
  List<WebseriesSeasonModel>? seasons;
  WebseriesItemModel? webseriesItem;

  Movies({
    this.id,
    this.title,
    this.movie_access,
    this.topten,
    this.trailer,
    this.certificate,
    this.duration,
    this.tagText,
    this.publishedDate,
    this.userlist,
    this.userlike,
    this.thumbnail,
    this.portraitsmall,
    this.portrait,
    this.usermovies,
    this.content,
    this.image,
    this.medium,
    this.isWebseries,
    this.seasons,
    this.webseriesItem,
  });

  factory Movies.fromJson(Map<String, dynamic> json) {
    List<WebseriesSeasonModel>? seasonsList;
    if (json['seasons'] != null && json['seasons'] is List) {
      seasonsList = (json['seasons'] as List)
          .map((x) => WebseriesSeasonModel.fromJson(x))
          .toList();
    }

    bool isWeb = json['is_webseries'] == true ||
        json['is_webseries'] == 1 ||
        (json['seasons'] != null && (json['seasons'] as List).isNotEmpty);

    WebseriesItemModel? webseries;
    if (isWeb) {
      try {
        webseries = WebseriesItemModel.fromJson(json);
      } catch (e) {
        // Fallback if parsing fails
      }
    }

    return Movies(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      movie_access: json['movie_access']?.toString(),
      topten: json['topten']?.toString(),
      trailer: json['trailer']?.toString(),
      certificate: json['certificate']?.toString(),
      duration: json['duration']?.toString(),
      tagText: json['tag_text']?.toString(),
      publishedDate: json['published_date']?.toString(),
      userlist: json['userlist']?.toString(),
      userlike: json['userlike']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      portraitsmall: json['portraitsmall']?.toString(),
      portrait: json['portrait']?.toString(),
      content: json['content_plain']?.toString() ?? json['content']?.toString(),
      image: json['image']?.toString(),
      medium: json['medium']?.toString(),
      isWebseries: isWeb,
      seasons: seasonsList,
      webseriesItem: webseries,
      usermovies: (json['usermovies'] != null &&
              json['usermovies'] is Map &&
              (json['usermovies'] as Map).isNotEmpty)
          ? Usermovies.fromJson(json['usermovies'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "movie_access": movie_access,
        "topten": topten,
        "trailer": trailer,
        "certificate": certificate,
        "duration": duration,
        "tag_text": tagText,
        "published_date": publishedDate.toString(),
        "userlist": userlist,
        "userlike": userlike,
        "thumbnail": thumbnail,
        "portraitsmall": portraitsmall,
        "portrait": portrait,
        "content": content,
        "image": image,
        "medium": medium,
        "is_webseries": isWebseries,
        "usermovies": usermovies?.toJson(),
      };
}
