import 'dart:convert';

SubscriptionListModel subscriptionListModelFromJson(String str) =>
    SubscriptionListModel.fromJson(json.decode(str));

String subscriptionListModelToJson(SubscriptionListModel data) =>
    json.encode(data.toJson());

class SubscriptionListModel {
  String? id;
  String? urlkey;
  String? title;
  String? content;
  int? before_price;
  int? price;
  String? tagtext;
  int? sortorder;
  String? razorpay_id;
  String? duration_text;

  SubscriptionListModel(
      {this.id,
      this.urlkey,
      this.title,
      this.content,
      this.before_price,
      this.price,
      this.tagtext,
      this.sortorder,
      this.razorpay_id,
      this.duration_text});

  factory SubscriptionListModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionListModel(
          id: json["id"] ?? "",
          urlkey: json["urlkey"] ?? "",
          title: json["title"] ?? "",
          content: json["content"] ?? "",
          before_price: json["before_price"] ?? 0,
          price: json["price"] ?? 0,
          tagtext: json["tagtext"] ?? "",
          sortorder: json["sortorder"] ?? 0,
          razorpay_id: json["razorpay_id"] ?? "",
          duration_text: json["duration_text"] ?? "");

  Map<String, dynamic> toJson() => {
        "id": id,
        "urlkey": urlkey,
        "title": title,
        "content": content,
        "before_price": before_price,
        "price": price,
        "tagtext": tagtext,
        "sortorder": sortorder,
        "razorpay_id": razorpay_id,
        "duration_text": duration_text,
      };
}
