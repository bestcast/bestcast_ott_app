import 'dart:convert';

WhoWatchingModel whoWatchingModelFromJson(String str) =>
    WhoWatchingModel.fromJson(json.decode(str));

String whoWatchingModelToJson(WhoWatchingModel data) =>
    json.encode(data.toJson());

class WhoWatchingModel {
  String? profileID;
  String? profileName;
  String? profilePictureID;
  String? profilePictureTitle;
  String? profilePicture;
  String? lastLogin;
  int? language;
  int? isChild;
  int? isHavePin;
  bool? editable;
  bool? enableAddUser;

  WhoWatchingModel(
      {this.profileID,
      this.profileName,
      this.profilePictureID,
      this.profilePictureTitle,
      this.profilePicture,
      this.lastLogin,
      this.language,
      this.isChild,
      this.isHavePin,
      this.editable,
      this.enableAddUser});

  factory WhoWatchingModel.fromJson(Map<String, dynamic> json) =>
      WhoWatchingModel(
          profileID: json["profileID"] ?? "",
          profileName: json["profileName"] ?? "",
          profilePictureID: json["profilePictureID"] ?? "",
          profilePictureTitle: json["profilePictureTitle"] ?? "",
          profilePicture: json["profilePicture"] ?? "",
          lastLogin: json["lastLogin"] ?? "",
          language: json["language"] ?? 0,
          isChild: json["isChild"] ?? 0,
          isHavePin: json["isHavePin"] ?? 0,
          editable: json["editable"] ?? false,
          enableAddUser: json["enableAddUser"] ?? false);

  Map<String, dynamic> toJson() => {
        "profileID": profileID,
        "profileName": profileName,
        "profilePictureID": profilePictureID,
        "profilePictureTitle": profilePictureTitle,
        "profilePicture": profilePicture,
        "lastLogin": lastLogin,
        "language": language,
        "isChild": isChild,
        "isHavePin": isHavePin,
        "editable": editable,
        "enableAddUser": enableAddUser
      };
}
