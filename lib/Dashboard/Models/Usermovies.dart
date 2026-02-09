class Usermovies {
  String? id;
  String? movieId;
  String? mylist;
  String? likes;
  String? watchTime;
  String? watching;
  String? watched;
  String? watchedPercent;
  String? viewed;

  Usermovies(
      {this.id,
      this.movieId,
      this.mylist,
      this.likes,
      this.watchTime,
      this.watching,
      this.watched,
      this.watchedPercent,
      this.viewed});

  factory Usermovies.fromJson(Map<String, dynamic> json) => Usermovies(
        id: json['id'].toString(),
        movieId: json['movie_id'].toString(),
        mylist: json['mylist'].toString(),
        likes: json['likes'].toString(),
        watchTime: json['watch_time'].toString(),
        watching: json['watching'].toString(),
        watched: json['watched'].toString(),
        watchedPercent: json['watched_percent'].toString(),
        viewed: json['viewed'].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "movie_id": movieId,
        "mylist": mylist,
        "likes": likes,
        "watch_time": watchTime,
        "watching": watching,
        "watched": watched,
        "watched_percent": watchedPercent,
        "viewed": viewed,
      };
}
