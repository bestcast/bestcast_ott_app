// Dart imports:
import 'dart:convert';

ProfileIconModel ProfileIconModelFromJson(String str) =>
    ProfileIconModel.fromJson(json.decode(str));

String ProfileIconModelToJson(ProfileIconModel data) =>
    json.encode(data.toJson());

class ProfileIconModel {
  String? profilePictureID;
  String? profilePictureTitle;
  String? profilePicture;

  ProfileIconModel(
      {this.profilePictureID, this.profilePictureTitle, this.profilePicture});

  factory ProfileIconModel.fromJson(Map<String, dynamic> json) =>
      ProfileIconModel(
        profilePictureID: json["profilePictureID"] ?? "",
        profilePictureTitle: json["profilePictureTitle"] ?? "",
        profilePicture: json["profilePicture"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "profilePictureID": profilePictureID,
        "profilePictureTitle": profilePictureTitle,
        "profilePicture": profilePicture
      };
}
