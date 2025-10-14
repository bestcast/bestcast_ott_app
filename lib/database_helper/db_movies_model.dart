class DbMovieModel {
  int? id;
  String? movieUrl;
  String? movieID;
  String? movieThumnail;
  String? movieTitle;

  DbMovieModel(
      {required this.id,
      required this.movieUrl,
      required this.movieID,
      required this.movieThumnail,
      required this.movieTitle});

  DbMovieModel.fromMap(Map<String, dynamic> json) {
    id = json["id"];
    movieUrl = json["movieUrl"];
    movieID = json["movieID"];
    movieThumnail = json["movieThumnail"];
    movieTitle = json["movieTitle"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['movieUrl'] = movieUrl;
    data['movieID'] = movieID;
    data['movieThumnail'] = movieThumnail;
    data['movieTitle'] = movieTitle;
    return data;
  }
}
