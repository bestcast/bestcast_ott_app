import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bestcaststudios/common_files/loading_widget.dart';
import '../app_config/app_preferences.dart';
import '../app_config/appconfig.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../streamingpalyer/video_player.dart';
import 'notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationModel> _notifications = [];

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";

  bool _loggedStatus = false;
  String _token = "";
  String _profileID = "";

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final pref = await SharedPreferences.getInstance();
      _token = pref.getString(AppPreferences.token) ?? '';
      _loggedStatus = pref.getBool(AppPreferences.loggedStatus) ?? false;
      _profileID = pref.getString(AppPreferences.profileID) ?? '';
    } catch (_) {}

    await _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    if (!mounted) return;

    if (_notifications.isEmpty) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = "";
      });
    }

    final bool hasToken = _token.trim().isNotEmpty;
    final String url = (_loggedStatus && hasToken && _profileID.isNotEmpty)
        ? "${AppConfig.appnotifylistuser}/$_profileID"
        : "${AppConfig.appnotifylist}/0";

    try {
      final response = hasToken
          ? await ApiServices().getRequestData(url, _token)
          : await ApiServices().getRequestWithoutToken(url);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final dynamic rawList = responseData["data"];

        final List<NotificationModel> fetched = [];

        if (rawList is List) {
          for (final dynamic item in rawList) {
            if (item is! Map) continue;

            final movieData = item["movie"];
            String movieID = "";
            String movieTitle = "";
            String thumbUrl = "";

            if (movieData != null && movieData is Map) {
              movieID = (movieData["id"] ?? "").toString();
              movieTitle = (movieData["title"] ?? "").toString();
              final rawMovieThumb = movieData["thumbnail"]?.toString() ?? "";
              if (rawMovieThumb.isNotEmpty) {
                thumbUrl = rawMovieThumb.startsWith('http')
                    ? rawMovieThumb
                    : "${AppConfig.BaseUrl}/$rawMovieThumb";
              }
            }

            if (thumbUrl.isEmpty) {
              final rawThumb = item["thumbnail"]?.toString() ?? "";
              if (rawThumb.isNotEmpty) {
                thumbUrl = rawThumb.startsWith('http')
                    ? rawThumb
                    : "${AppConfig.BaseUrl}/$rawThumb";
              }
            }

            final dynamic rawDesc = item["description"] ?? item["message"];
            final String desc = (rawDesc != null &&
                    rawDesc.toString().trim().isNotEmpty &&
                    rawDesc.toString().trim() != "Notification Description")
                ? rawDesc.toString().trim()
                : "";

            fetched.add(
              NotificationModel(
                notificationID: (item["id"] ?? "").toString(),
                movieID: movieID,
                title: (item["title"] ?? "Notification").toString(),
                description: desc,
                movieName: movieTitle,
                thumnail: thumbUrl,
                notificationDate: (item["created_at"] ?? "").toString(),
                isRead: item["is_read"] == 1 ||
                    item["is_read"] == "1" ||
                    item["is_read"] == true,
              ),
            );
          }
        }

        setState(() {
          _notifications.clear();
          _notifications.addAll(fetched);
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = _notifications.isEmpty;
          _errorMessage = "Unable to load notifications";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = _notifications.isEmpty;
        _errorMessage = "Network error. Please try again.";
      });
    }
  }

  void _onNotificationTapped(NotificationModel notification) {
    HapticFeedback.lightImpact();

    final String movieID = (notification.movieID ?? "").trim();
    if (movieID.isNotEmpty && movieID != "0" && movieID != "null") {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => VideoApp(getMovieID: movieID),
        ),
      );
    } else if (notification.description != null &&
        notification.description!.isNotEmpty) {
      _showNotificationDetailDialog(notification);
    }
  }

  void _showNotificationDetailDialog(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16161A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                notification.title ?? "Notification",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (notification.movieName != null &&
                  notification.movieName!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  notification.movieName!,
                  style: const TextStyle(
                    color: AppDefaultColors.primaryRed,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                notification.description ?? "",
                style: const TextStyle(
                  color: AppDefaultColors.textLightGray,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _formatNotificationTime(notification.notificationDate),
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatNotificationTime(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '';
    try {
      final parsed = DateTime.tryParse(dateStr);
      if (parsed == null) return dateStr;
      final now = DateTime.now();
      final difference = now.difference(parsed);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        final mins = difference.inMinutes;
        return '$mins ${mins == 1 ? 'min' : 'mins'} ago';
      } else if (difference.inHours < 24) {
        final hours = difference.inHours;
        return '$hours ${hours == 1 ? 'hr' : 'hrs'} ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
      }
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 20,
          title: const Text(
            "Notifications",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppDefaultColors.primaryRed,
      backgroundColor: const Color(0xFF1E1E24),
      onRefresh: _fetchNotifications,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => const Divider(
          color: Color(0xFF1C1C20),
          height: 1,
          thickness: 0.8,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final item = _notifications[index];
          return _buildNotificationItem(item);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel item) {
    final String timeAgo = _formatNotificationTime(item.notificationDate);

    final String title = (item.title ?? "").trim();
    final String movieName = (item.movieName ?? "").trim();
    final String desc = (item.description ?? "").trim();

    final String displayTitle = title.isNotEmpty ? title : movieName;

    String? displaySubtitle;
    if (desc.isNotEmpty &&
        desc.toLowerCase() != title.toLowerCase() &&
        desc.toLowerCase() != "notification description") {
      displaySubtitle = desc;
    } else if (movieName.isNotEmpty &&
        movieName.toLowerCase() != title.toLowerCase() &&
        !title.toLowerCase().contains(movieName.toLowerCase())) {
      displaySubtitle = movieName;
    }

    return InkWell(
      onTap: () => _onNotificationTapped(item),
      splashColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Clean 16:9 thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 104,
                height: 60,
                color: const Color(0xFF1E1E22),
                child: item.thumnail != null && item.thumnail!.trim().isNotEmpty
                    ? Image.network(
                        item.thumnail!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackThumbnail(),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(color: const Color(0xFF1E1E22));
                        },
                      )
                    : _buildFallbackThumbnail(),
              ),
            ),

            const SizedBox(width: 14),

            // Notification text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayTitle.isNotEmpty ? displayTitle : "Notification",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: !item.isRead ? FontWeight.w600 : FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                  if (displaySubtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      displaySubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (timeAgo.isNotEmpty)
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11.5,
                          ),
                        ),
                      if (!item.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: AppDefaultColors.primaryRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      color: const Color(0xFF1E1E22),
      child: const Center(
        child: Icon(
          Icons.notifications_none_rounded,
          color: Colors.white24,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: AppDefaultColors.primaryRed,
      backgroundColor: const Color(0xFF1E1E24),
      onRefresh: _fetchNotifications,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 44,
                    color: Colors.white24,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: Colors.white24,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage.isNotEmpty ? _errorMessage : "Couldn't load notifications",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _fetchNotifications,
            child: const Text(
              "Retry",
              style: TextStyle(
                color: AppDefaultColors.primaryRed,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
