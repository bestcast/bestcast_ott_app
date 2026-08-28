class WebseriesBlockModel {
  final String id;
  final String title;
  final List<WebseriesItemModel> webseriesList;

  WebseriesBlockModel({
    required this.id,
    required this.title,
    required this.webseriesList,
  });

  factory WebseriesBlockModel.fromJson(Map<String, dynamic> json) {
    var rawList = json['movies'] ?? json['webseries'] ?? [];
    List<WebseriesItemModel> list = [];
    if (rawList is List) {
      list = rawList.map((x) => WebseriesItemModel.fromJson(x)).toList();
    }
    return WebseriesBlockModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      webseriesList: list,
    );
  }
}

class WebseriesItemModel {
  final String id;
  final String title;
  final String content;
  final String publishedDate;
  final String certificate;
  final String tagText;
  final String thumbnail;
  final String image;
  final String medium;
  final String portrait;
  final String portraitsmall;
  final int movieAccess;
  final String trailer;
  final int topten;
  final String? resumeEpisodeId;
  final String? resumeDate;
  final String? firstEpisodeId;
  final List<WebseriesSeasonModel> seasons;
  final List<WebseriesCastModel> casts;

  WebseriesItemModel({
    required this.id,
    required this.title,
    this.content = '',
    this.publishedDate = '',
    this.certificate = '',
    this.tagText = '',
    this.thumbnail = '',
    this.image = '',
    this.medium = '',
    this.portrait = '',
    this.portraitsmall = '',
    this.movieAccess = 0,
    this.trailer = '',
    this.topten = 0,
    this.resumeEpisodeId,
    this.resumeDate,
    this.firstEpisodeId,
    required this.seasons,
    this.casts = const [],
  });

  factory WebseriesItemModel.fromJson(Map<String, dynamic> json) {
    List<WebseriesSeasonModel> seasonsList = [];
    if (json['seasons'] != null && json['seasons'] is List) {
      seasonsList = (json['seasons'] as List)
          .map((x) => WebseriesSeasonModel.fromJson(x))
          .toList();
    }

    List<WebseriesCastModel> castList = [];
    if (json['casts'] != null && json['casts'] is List) {
      castList = (json['casts'] as List)
          .map((x) => WebseriesCastModel.fromJson(x))
          .toList();
    }

    return WebseriesItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      publishedDate: json['published_date']?.toString() ?? '',
      certificate: json['certificate']?.toString() ?? '',
      tagText: json['tag_text']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      medium: json['medium']?.toString() ?? '',
      portrait: json['portrait']?.toString() ?? '',
      portraitsmall: json['portraitsmall']?.toString() ?? '',
      movieAccess: int.tryParse(json['movie_access']?.toString() ?? '0') ?? 0,
      trailer: json['trailer']?.toString() ?? '',
      topten: int.tryParse(json['topten']?.toString() ?? '0') ?? 0,
      resumeEpisodeId: json['resume_episode_id']?.toString(),
      resumeDate: json['resume_date']?.toString(),
      firstEpisodeId: json['first_episode_id']?.toString(),
      seasons: seasonsList,
      casts: castList,
    );
  }
}

class WebseriesSeasonModel {
  final String id;
  final String title;
  final int seasonNumber;
  final List<WebseriesEpisodeModel> episodes;

  WebseriesSeasonModel({
    required this.id,
    required this.title,
    this.seasonNumber = 1,
    required this.episodes,
  });

  factory WebseriesSeasonModel.fromJson(Map<String, dynamic> json) {
    List<WebseriesEpisodeModel> episodeList = [];
    if (json['episodes'] != null && json['episodes'] is List) {
      episodeList = (json['episodes'] as List)
          .map((x) => WebseriesEpisodeModel.fromJson(x))
          .toList();
    }

    return WebseriesSeasonModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      seasonNumber: int.tryParse(json['season_number']?.toString() ?? '1') ?? 1,
      episodes: episodeList,
    );
  }
}

class WebseriesEpisodeModel {
  final String id;
  final String title;
  final String urlkey;
  final String content;
  final String contentPlain;
  final String image;
  final String medium;
  final String thumbnail;
  final String portrait;
  final String portraitsmall;
  final String duration;
  final String durationSecs;
  final String durationText;
  final String releaseDate;
  final String publishedDate;
  final String certificate;
  final int movieAccess;
  final String trailer;
  final String videoUrl;
  final String moviesource;
  final EpisodeUserModel? episodeUser;

  WebseriesEpisodeModel({
    required this.id,
    required this.title,
    this.urlkey = '',
    this.content = '',
    this.contentPlain = '',
    this.image = '',
    this.medium = '',
    this.thumbnail = '',
    this.portrait = '',
    this.portraitsmall = '',
    this.duration = '',
    this.durationSecs = '0',
    this.durationText = '',
    this.releaseDate = '',
    this.publishedDate = '',
    this.certificate = '',
    this.movieAccess = 0,
    this.trailer = '',
    this.videoUrl = '',
    this.moviesource = '',
    this.episodeUser,
  });

  factory WebseriesEpisodeModel.fromJson(Map<String, dynamic> json) {
    EpisodeUserModel? userProgress;
    if (json['episode_user'] != null && json['episode_user'] is Map) {
      userProgress = EpisodeUserModel.fromJson(json['episode_user']);
    }

    String video = json['video_url']?.toString() ??
        json['moviesource']?.toString() ??
        '';

    return WebseriesEpisodeModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      urlkey: json['urlkey']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      contentPlain: json['content_plain']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      medium: json['medium']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      portrait: json['portrait']?.toString() ?? '',
      portraitsmall: json['portraitsmall']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      durationSecs: json['duration_secs']?.toString() ??
          json['duration']?.toString() ??
          '0',
      durationText: json['duration_text']?.toString() ?? '',
      releaseDate: json['release_date']?.toString() ?? '',
      publishedDate: json['published_date']?.toString() ?? '',
      certificate: json['certificate']?.toString() ?? '',
      movieAccess: int.tryParse(json['movie_access']?.toString() ?? '0') ?? 0,
      trailer: json['trailer']?.toString() ?? '',
      videoUrl: video,
      moviesource: video,
      episodeUser: userProgress,
    );
  }
}

class EpisodeUserModel {
  final String watchTime;
  final double watchedPercent;
  final int watched;
  final int watching;

  EpisodeUserModel({
    this.watchTime = '0',
    this.watchedPercent = 0.0,
    this.watched = 0,
    this.watching = 0,
  });

  factory EpisodeUserModel.fromJson(Map<String, dynamic> json) {
    double percent = 0.0;
    if (json['watched_percent'] != null) {
      percent = double.tryParse(json['watched_percent'].toString()) ?? 0.0;
    }
    return EpisodeUserModel(
      watchTime: json['watch_time']?.toString() ?? '0',
      watchedPercent: percent,
      watched: int.tryParse(json['watched']?.toString() ?? '0') ?? 0,
      watching: int.tryParse(json['watching']?.toString() ?? '0') ?? 0,
    );
  }
}

class WebseriesCastModel {
  final String name;
  final int group;
  final String groupName;

  WebseriesCastModel({
    required this.name,
    this.group = 0,
    this.groupName = '',
  });

  factory WebseriesCastModel.fromJson(Map<String, dynamic> json) {
    return WebseriesCastModel(
      name: json['name']?.toString() ?? '',
      group: int.tryParse(json['group']?.toString() ?? '0') ?? 0,
      groupName: json['group_name']?.toString() ?? '',
    );
  }
}

class WebseriesBannerModel {
  final String id;
  final String title;
  final String image;
  final String thumbnail;
  final String logo;
  final WebseriesItemModel? webseries;

  WebseriesBannerModel({
    required this.id,
    required this.title,
    this.image = '',
    this.thumbnail = '',
    this.logo = '',
    this.webseries,
  });

  factory WebseriesBannerModel.fromJson(Map<String, dynamic> json) {
    WebseriesItemModel? series;
    if (json['movies'] != null && json['movies'] is Map) {
      series = WebseriesItemModel.fromJson(json['movies']);
    }
    return WebseriesBannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
      webseries: series,
    );
  }
}
