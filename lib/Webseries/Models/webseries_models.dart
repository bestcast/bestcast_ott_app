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
    Map<String, dynamic> movieData = {};
    if (json['movies'] != null && json['movies'] is Map<String, dynamic>) {
      movieData = json['movies'];
    } else if (json['webseries'] != null && json['webseries'] is Map<String, dynamic>) {
      movieData = json['webseries'];
    }

    String getString(String key, [String fallbackKey = '']) {
      var val = json[key] ?? movieData[key];
      if ((val == null || val.toString() == 'null' || val.toString().trim().isEmpty) && fallbackKey.isNotEmpty) {
        val = json[fallbackKey] ?? movieData[fallbackKey];
      }
      if (val == null || val.toString() == 'null') return '';
      return val.toString().trim();
    }

    List<WebseriesSeasonModel> seasonsList = [];
    var rawSeasons = json['seasons'] ?? movieData['seasons'];
    if (rawSeasons != null && rawSeasons is List) {
      seasonsList = rawSeasons
          .map((x) => WebseriesSeasonModel.fromJson(x))
          .toList();
    }

    List<WebseriesCastModel> castList = [];
    var rawCasts = json['casts'] ?? movieData['casts'];
    if (rawCasts != null && rawCasts is List) {
      castList = rawCasts
          .map((x) => WebseriesCastModel.fromJson(x))
          .where((c) => c.name.isNotEmpty)
          .toList();
    }

    String image = getString('image', 'banner');
    if (image.isEmpty) image = getString('banner_image', 'poster');
    if (image.isEmpty) image = getString('medium', 'thumbnail');

    String thumbnail = getString('thumbnail', 'image');
    if (thumbnail.isEmpty) thumbnail = getString('medium', 'portraitsmall');

    String medium = getString('medium', 'image');
    String portrait = getString('portrait', 'portraitsmall');
    String portraitsmall = getString('portraitsmall', 'portrait');

    return WebseriesItemModel(
      id: getString('id'),
      title: getString('title'),
      content: getString('content', 'content_plain'),
      publishedDate: getString('published_date'),
      certificate: getString('certificate'),
      tagText: getString('tag_text'),
      thumbnail: thumbnail,
      image: image,
      medium: medium,
      portrait: portrait,
      portraitsmall: portraitsmall,
      movieAccess: int.tryParse(getString('movie_access')) ?? 0,
      trailer: getString('trailer'),
      topten: int.tryParse(getString('topten')) ?? 0,
      resumeEpisodeId: getString('resume_episode_id').isNotEmpty ? getString('resume_episode_id') : null,
      resumeDate: getString('resume_date').isNotEmpty ? getString('resume_date') : null,
      firstEpisodeId: getString('first_episode_id').isNotEmpty ? getString('first_episode_id') : null,
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
    String name = json['name']?.toString() ?? '';
    if ((name.isEmpty || name == 'null') && json['cast'] != null && json['cast'] is Map) {
      name = json['cast']['name']?.toString() ??
          "${json['cast']['firstname'] ?? ''} ${json['cast']['lastname'] ?? ''}".trim();
    }
    String groupName = json['group_name']?.toString() ??
        json['group_label']?.toString() ??
        '';
    if (name == 'null') name = '';
    if (groupName == 'null') groupName = '';

    return WebseriesCastModel(
      name: name.trim(),
      group: int.tryParse(json['group']?.toString() ?? '0') ?? 0,
      groupName: groupName.trim(),
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
    } else if (json['webseries'] != null && json['webseries'] is Map) {
      series = WebseriesItemModel.fromJson(json['webseries']);
    }

    String img = json['image']?.toString() ??
        json['banner']?.toString() ??
        json['banner_image']?.toString() ??
        series?.image ??
        '';
    if (img == 'null') img = '';

    String thumb = json['thumbnail']?.toString() ??
        series?.thumbnail ??
        '';
    if (thumb == 'null') thumb = '';

    return WebseriesBannerModel(
      id: json['id']?.toString() ?? series?.id ?? '',
      title: json['title']?.toString() ?? series?.title ?? '',
      image: img,
      thumbnail: thumb,
      logo: json['logo']?.toString() ?? '',
      webseries: series,
    );
  }
}
