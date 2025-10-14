// Project imports:
import 'Movie.dart';

// MoviesMainCategoryModel moviesCategoryModelFromJson(String str) => MoviesMainCategoryModel.fromJson(json.decode(str));
//
// String moviesCategoryModelToJson(MoviesMainCategoryModel data) => json.encode(data.toJson());
//
// class MoviesMainCategoryModel {
//   String? id;
//   String? title;
//   String? topten;
//   String? trailer;
//   String? certificate;
//   String? duration;
//   String? tagText;
//   String? publishedDate;
//   String? userlist;
//   String? userlike;
//   String? thumbnail;
//   String? portraitsmall;
//   String? portrait;
//   Usermovies? usermovies;
//
//   MoviesMainCategoryModel(
//       {this.id,
//       this.title,
//       this.topten,
//       this.trailer,
//       this.certificate,
//       this.duration,
//       this.tagText,
//       this.publishedDate,
//       this.userlist,
//       this.userlike,
//       this.thumbnail,
//       this.portraitsmall,
//       this.portrait,
//       this.usermovies});
//
//   factory MoviesMainCategoryModel.fromJson(Map<String, dynamic> json) => MoviesMainCategoryModel(
//     id : json['id'].toString()==null?"":json['id'].toString(),
//     title : json['title'].toString()==null?"":json['title'].toString(),
//     topten : json['topten'].toString()==null?"":json['topten'].toString(),
//     trailer : json['trailer'].toString()==null?"":json['trailer'].toString(),
//     certificate : json['certificate'].toString()==null?"":json['certificate'].toString(),
//     duration : json['duration'].toString()==null?"":json['duration'].toString(),
//     tagText : json['tag_text'].toString()==null?"":json['tag_text'].toString(),
//     publishedDate : json['published_date'].toString()==null?"":json['published_date'].toString(),
//     userlist : json['userlist'].toString()==null?"":json['userlist'].toString(),
//     userlike : json['userlike'].toString()==null?"":json['userlike'].toString(),
//     thumbnail : json['thumbnail'].toString()==null?"":json['thumbnail'].toString(),
//     portraitsmall : json['portraitsmall'].toString()==null?"":json['portraitsmall'].toString(),
//     portrait : json['portrait'].toString()==null?"":json['portrait'].toString(),
//     usermovies : (json['usermovies'] != null ? new Usermovies.fromJson(json['usermovies']) : null)!,
//     );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "title": title,
//     "topten": topten,
//     "trailer": trailer,
//     "certificate": certificate,
//     "duration": duration,
//     "tag_text": tagText,
//     "published_date": publishedDate.toString(),
//     "userlist": userlist,
//     "userlike": userlike,
//     "thumbnail": thumbnail,
//     "portraitsmall": portraitsmall,
//     "portrait": portrait,
//     "usermovies": usermovies?.toJson(),
//   };
// }
//
// MoviesMainCategoryModel moviesMainCategoryModelFromJson(String str) => MoviesMainCategoryModel.fromJson(json.decode(str));
//
// String moviesMainCategoryModelToJson(MoviesMainCategoryModel data) => json.encode(data.toJson());

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
        id: json["id"].toString() ?? "",
        title: json["title"].toString() ?? "",
        movies:
            List<Movies>.from(json["movies"].map((x) => Movies.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "movies": List<dynamic>.from(movies!.map((x) => x.toJson())),
      };
}
