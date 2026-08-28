import 'dart:convert';
import 'package:bestcaststudios/app_config/appconfig.dart';
import 'package:bestcaststudios/common_files/api_services.dart';
import 'Models/webseries_models.dart';

class WebseriesApiService {
  final ApiServices _apiServices = ApiServices();

  // 1. Get Webseries Blocks List (Home / Section)
  Future<List<WebseriesBlockModel>> getWebseriesBlocksList({
    required String token,
    required String profileId,
    int pageId = 1,
    String? genreId,
    String? languageId,
  }) async {
    String url = "${AppConfig.webseriesblockslist}$pageId";
    if (profileId.isNotEmpty) {
      url += "&profile_id=$profileId";
    }
    if (genreId != null && genreId.isNotEmpty) {
      url += "&genre_id=$genreId";
    }
    if (languageId != null && languageId.isNotEmpty) {
      url += "&language_id=$languageId";
    }

    try {
      final response = token.isNotEmpty
          ? await _apiServices.getRequestData(url, token)
          : await _apiServices.getRequestWithoutToken(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> dataList = jsonResponse['data'] ?? [];
        return dataList.map((x) => WebseriesBlockModel.fromJson(x)).toList();
      }
    } catch (e) {
      print("Error fetching webseries blocks list: $e");
    }
    return [];
  }

  // 2. Get Season Episode Banner List
  Future<WebseriesBannerModel?> getSeasonEpisodeBannerList({
    required String token,
    required String webseriesId,
    required String profileId,
  }) async {
    String url = "${AppConfig.seasonepisodebannerlist}$webseriesId";
    if (profileId.isNotEmpty) {
      url += "?profile_id=$profileId";
    }

    try {
      final response = token.isNotEmpty
          ? await _apiServices.getRequestData(url, token)
          : await _apiServices.getRequestWithoutToken(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] != null) {
          return WebseriesBannerModel.fromJson(jsonResponse['data']);
        }
      }
    } catch (e) {
      print("Error fetching season episode banner list: $e");
    }
    return null;
  }

  // 3. Get Webseries Watch Detail
  Future<WebseriesItemModel?> getWebseriesWatchDetail({
    required String token,
    required String webseriesId,
    required String profileId,
  }) async {
    String url = "${AppConfig.webserieswatchdetail}$webseriesId";
    if (profileId.isNotEmpty) {
      url += "?profile_id=$profileId";
    }

    try {
      final response = token.isNotEmpty
          ? await _apiServices.getRequestData(url, token)
          : await _apiServices.getRequestWithoutToken(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] != null) {
          return WebseriesItemModel.fromJson(jsonResponse['data']);
        }
      }
    } catch (e) {
      print("Error fetching webseries watch detail: $e");
    }
    return null;
  }

  // 4. Get Webseries Full Detail (Deep Link / Share / Casts)
  Future<WebseriesItemModel?> getWebseriesDetail({
    required String token,
    required String webseriesId,
    required String profileId,
  }) async {
    String url = "${AppConfig.getwebseriesdetail}$webseriesId";
    if (profileId.isNotEmpty) {
      url += "?profile_id=$profileId";
    }

    try {
      final response = token.isNotEmpty
          ? await _apiServices.getRequestData(url, token)
          : await _apiServices.getRequestWithoutToken(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] != null) {
          return WebseriesItemModel.fromJson(jsonResponse['data']);
        }
      }
    } catch (e) {
      print("Error fetching webseries detail: $e");
    }
    return null;
  }

  // 5. Set User Episode Watch Progress
  Future<bool> setUserEpisodeProgress({
    required String token,
    required String profileId,
    required String episodeId,
    required int watchTime,
    required int watchedPercent,
    int watching = 1,
    int watched = 0,
    int movieDuration = 0,
  }) async {
    String url = "${AppConfig.setuserepisode}$episodeId";
    if (profileId.isNotEmpty) {
      url += "?profile_id=$profileId";
    }

    final postValues = {
      "watch_time": watchTime,
      "watching": watching,
      "watched_percent": watchedPercent,
      "watched": watched,
      "movieDuration": movieDuration,
    };

    try {
      final response = token.isNotEmpty
          ? await _apiServices.postRequestToken(url, postValues, token)
          : await _apiServices.postRequest(url, postValues);

      return response.statusCode == 200;
    } catch (e) {
      print("Error setting user episode progress: $e");
    }
    return false;
  }
}
