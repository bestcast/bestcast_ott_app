class SubTitleModel {
  String? active;
  String? label;
  String? url;

  SubTitleModel({
    required this.active,
    required this.label,
    required this.url,
  });

  factory SubTitleModel.fromJson(Map<String, dynamic> json) => SubTitleModel(
        active: json["active"].toString() ?? "",
        label: json["label"].toString() ?? "",
        url: json["url"].toString() ?? "",
      );

  Map<String, dynamic> toJson() =>
      {"active": active, "label": label, "url": url};
}
