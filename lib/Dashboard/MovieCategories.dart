// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:bestcaststudios/Dashboard/MoviesModels.dart';

MoviesCategoryModel moviesCategoryModelFromJson(String str) =>
    MoviesCategoryModel.fromJson(json.decode(str));

String moviesCategoryModelToJson(MoviesCategoryModel data) =>
    json.encode(data.toJson());

class MoviesCategoryModel {
  String? catogoryID;
  String? catogoryName;
  List<MoviesModel?>? moviesModel;

  MoviesCategoryModel({this.catogoryID, this.catogoryName, this.moviesModel});

  MoviesCategoryModel.fromJson(Map<String, dynamic> json) {
    catogoryID = json['catogoryID'];
    catogoryName = json['catogoryName'];
    if (json['moviesModel'] != null) {
      moviesModel = <MoviesModel>[];
      json['moviesModel'].forEach((v) {
        moviesModel!.add(MoviesModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['catogoryID'] = catogoryID;
    data['catogoryName'] = catogoryName;
    data['moviesModel'] = moviesModel?.map((v) => v?.toJson()).toList();
    return data;
  }
}
