import 'dart:convert';

NotificationModel moviesModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));

String moviesModelToJson(NotificationModel data) => json.encode(data.toJson());

class NotificationModel {
  String? notificationID;
  String? movieID;
  String? title;
  String? description;
  String? movieName;
  String? thumnail;
  String? notificationDate;
  bool isRead;

  NotificationModel({
    this.notificationID,
    this.movieID,
    this.title,
    this.description,
    this.movieName,
    this.thumnail,
    this.notificationDate,
    this.isRead = false,
  });

  NotificationModel.fromJson(Map<String, dynamic> json)
      : isRead = json['isRead'] == true || json['is_read'] == 1 || json['is_read'] == '1' {
    notificationID = json['notificationID'];
    movieID = json['movieID'];
    title = json['title'];
    description = json['description'];
    movieName = json['movieName'];
    thumnail = json['thumnail'];
    notificationDate = json['notificationDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['notificationID'] = notificationID;
    data['movieID'] = movieID;
    data['title'] = title;
    data['description'] = description;
    data['movieName'] = movieName;
    data['thumnail'] = thumnail;
    data['notificationDate'] = notificationDate;
    data['isRead'] = isRead;
    return data;
  }
}
