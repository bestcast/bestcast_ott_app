import 'dart:convert';

import 'package:http/http.dart';

class ApiServices {
  Future<Response> postData(String url, final jsonValues) async {
    final encoding = Encoding.getByName('utf-8');
    final response = await post(Uri.parse(url),
        headers: <String, String>{
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: jsonValues,
        encoding: encoding);
    return response;
  }

  Future<Response> getData(String url, String token) async {
    final response = await get(Uri.parse(url), headers: <String, String>{
      "Content-Type": "application/x-www-form-urlencoded"
    });
    return response;
  }

  Future<Response> getRequestData(String url, String token) async {
    final response = await get(Uri.parse(url), headers: {
      "Content-Type": "application/json; charset=UTF-8",
      "Accept": "application/json",
      'Authorization': 'Bearer $token'
    });
    return response;
  }

  Future<Response> getRequestWithoutToken(String url) async {
    final response = await get(Uri.parse(url), headers: {
      "Content-Type": "application/json; charset=UTF-8",
      "Accept": "application/json"
    });
    return response;
  }

  Future<Response> postRequest(String url, final jsonValues) async {
    var body = jsonEncode(jsonValues);
    var response = await post(Uri.parse(url),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Accept": "application/json"
        },
        body: body);
    print("postData status code:${response.statusCode}");
    print("postData Body: ${response.body}");
    return response;
  }

  Future<Response> postRequestToken(
      String url, final jsonValues, String token) async {
    var body = jsonEncode(jsonValues);
    var response = await post(Uri.parse(url),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: body);
    print("postData status code:${response.statusCode}");
    print("postData Body: ${response.body}");
    return response;
  }

  Future<Response> postRequestTokenWithoutBody(String url, String token) async {
    var response = await post(Uri.parse(url), headers: {
      "Content-Type": "application/json; charset=UTF-8",
      "Accept": "application/json",
      'Authorization': 'Bearer $token',
    });
    print("postData status code:${response.statusCode}");
    print("postData Body: ${response.body}");
    return response;
  }

  Future<Response> getRequestToken(
      String url, final jsonValues, String token) async {
    var body = jsonEncode(jsonValues);
    var response = await post(Uri.parse(url),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: body);
    print("postData status code:${response.statusCode}");
    print("postData Body: ${response.body}");
    return response;
  }
}
