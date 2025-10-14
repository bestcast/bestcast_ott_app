class CastElement {
  String? group;
  String? groupLabel;
  String? groupSlug;
  CastCast? cast;

  CastElement({
    required this.group,
    required this.groupLabel,
    required this.groupSlug,
    required this.cast,
  });

  factory CastElement.fromJson(Map<String, dynamic> json) => CastElement(
        group: json["group"].toString() ?? "",
        groupLabel: json["group_label"].toString() ?? "",
        groupSlug: json["group_slug"].toString() ?? "",
        cast: CastCast.fromJson(json["cast"]),
      );

  Map<String, dynamic> toJson() => {
        "group": group,
        "group_label": groupLabel,
        "group_slug": groupSlug,
        "cast": cast?.toJson(),
      };
}

class CastCast {
  String? id;
  String? name;
  String? firstname;
  String? lastname;
  String? dob;
  String? gender;
  String? photo;

  CastCast({
    this.id,
    this.name,
    this.firstname,
    this.lastname,
    this.dob,
    this.gender,
    this.photo,
  });

  factory CastCast.fromJson(Map<String, dynamic> json) => CastCast(
        id: json["id"].toString() ?? "",
        name: json["name"].toString() ?? "",
        firstname: json["firstname"].toString() ?? "",
        lastname: json["lastname"].toString() ?? "",
        dob: json["dob"].toString() ?? "",
        gender: json["gender"].toString() ?? "",
        photo: json["photo"].toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "firstname": firstname,
        "lastname": lastname,
        "dob": dob,
        "gender": gender,
        "photo": photo,
      };
}
