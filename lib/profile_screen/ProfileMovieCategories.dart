// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:bestcaststudios/Dashboard/Models/Movie.dart';

ProfileMoviesCategoryModel moviesCategoryModelFromJson(String str) =>
    ProfileMoviesCategoryModel.fromJson(json.decode(str));

String moviesCategoryModelToJson(ProfileMoviesCategoryModel data) =>
    json.encode(data.toJson());

class ProfileMoviesCategoryModel {
  String? catogoryID;
  String? catogoryName;
  List<Movies>? moviesMylistModel;
  List<Movies>? moviesWatchingModel;
  List<Movies>? moviesRWatchedModel;

  ProfileMoviesCategoryModel(
      {this.catogoryID,
      this.catogoryName,
      this.moviesMylistModel,
      this.moviesWatchingModel,
      this.moviesRWatchedModel});

  ProfileMoviesCategoryModel.fromJson(Map<String, dynamic> json) {
    catogoryID = json['catogoryID'];
    catogoryName = json['catogoryName'];
    if (json['moviesMylistModel'] != null) {
      moviesMylistModel = <Movies>[];
      json['moviesMylistModel'].forEach((v) {
        moviesMylistModel!.add(Movies.fromJson(v));
      });
    }
    if (json['moviesWatchingModel'] != null) {
      moviesWatchingModel = <Movies>[];
      json['moviesWatchingModel'].forEach((v) {
        moviesWatchingModel!.add(Movies.fromJson(v));
      });
    }
    if (json['moviesModel'] != null) {
      moviesRWatchedModel = <Movies>[];
      json['moviesRWatchedModel'].forEach((v) {
        moviesRWatchedModel!.add(Movies.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['catogoryID'] = catogoryID;
    data['catogoryName'] = catogoryName;
    data['moviesMylistModel'] =
        moviesMylistModel?.map((v) => v.toJson()).toList();
    data['moviesWatchingModel'] =
        moviesWatchingModel?.map((v) => v.toJson()).toList();
    data['moviesRWatchedModel'] =
        moviesRWatchedModel?.map((v) => v.toJson()).toList();
    return data;
  }
}
