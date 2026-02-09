import 'dart:convert';

import 'package:bestcaststudios/Dashboard/Models/Usermovies.dart';

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

  Movies(
      {this.id,
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
      this.usermovies});

  factory Movies.fromJson(Map<String, dynamic> json) => Movies(
        id: json['id'].toString(),
        title: json['title'].toString(),
        movie_access: json['movie_access'].toString(),
        topten: json['topten'].toString(),
        trailer: json['trailer'].toString(),
        certificate: json['certificate'].toString(),
        duration: json['duration'].toString(),
        tagText: json['tag_text'].toString(),
        publishedDate: json['published_date'].toString(),
        userlist: json['userlist'].toString(),
        userlike: json['userlike'].toString(),
        thumbnail: json['thumbnail'].toString(),
        portraitsmall: json['portraitsmall'].toString(),
        portrait: json['portrait'].toString(),
        usermovies: (json['usermovies'] != ""
            ? Usermovies.fromJson(json['usermovies'])
            : null)!,
      );

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
        "usermovies": usermovies?.toJson(),
      };
}
