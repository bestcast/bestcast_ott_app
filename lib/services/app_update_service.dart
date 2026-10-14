import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

/// Defines the strategy used when an update is available on Google Play.
enum AppUpdateMode {
  /// Intelligently chooses between immediate and flexible updates.
  /// If updatePriority >= 4 or clientVersionStalenessDays >= 7, triggers an immediate update.
  /// Otherwise triggers a flexible background update if allowed.
  auto,

  /// Forces a full-screen, blocking update flow.
  immediate,

  /// Downloads the update in the background while the user continues using the app.
  flexible,
}

class AppUpdateService {
  static bool _isChecking = false;
  static DateTime? _lastCheckTime;

  /// Checks for available app updates on Google Play and triggers the appropriate flow.
  ///
  /// - [mode]: Update mode (defaults to [AppUpdateMode.auto]).
  /// - [force]: If true, bypasses the [cooldown] timer.
  /// - [cooldown]: Time interval before checking Google Play again (defaults to 15 minutes).
  /// - [onFlexibleUpdateDownloaded]: Callback invoked when a flexible update has finished
  ///   downloading and is ready to be installed via [completeFlexibleUpdate].
  static Future<void> checkForUpdate({
    AppUpdateMode mode = AppUpdateMode.auto,
    bool force = false,
    Duration cooldown = const Duration(minutes: 15),
    VoidCallback? onFlexibleUpdateDownloaded,
  }) async {
    // In-App Updates are only supported on Android.
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    // Prevent concurrent checks
    if (_isChecking) {
      return;
    }

    // Debounce / throttle checks
    final now = DateTime.now();
    if (!force && _lastCheckTime != null && now.difference(_lastCheckTime!) < cooldown) {
      return;
    }

    _isChecking = true;
    _lastCheckTime = now;

    try {
      final info = await InAppUpdate.checkForUpdate();

      // Case 1: An immediate update was previously started and interrupted (e.g., app was killed).
      // Google Play requires resuming the immediate update flow on launch.
      if (info.updateAvailability == UpdateAvailability.developerTriggeredUpdateInProgress) {
        debugPrint('Bestcast InAppUpdate: Resuming in-progress immediate update');
        await InAppUpdate.performImmediateUpdate();
        return;
      }

      // Case 2: A flexible update has finished downloading in the background.
      if (info.installStatus == InstallStatus.downloaded) {
        debugPrint('Bestcast InAppUpdate: Flexible update already downloaded');
        onFlexibleUpdateDownloaded?.call();
        return;
      }

      // Case 3: An update is available.
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await _handleUpdate(
          info: info,
          mode: mode,
          onFlexibleUpdateDownloaded: onFlexibleUpdateDownloaded,
        );
      }
    } catch (e) {
      debugPrint('Bestcast InAppUpdate: Update check/execution failed: $e');
      if (kDebugMode) {
        debugPrint(
          'Bestcast InAppUpdate [Hint]: In-App Updates only function when the app '
          'is installed from Google Play or Google Play Internal App Sharing.',
        );
      }
    } finally {
      _isChecking = false;
    }
  }

  /// Completes a flexible update by restarting the app to apply the newly downloaded version.
  static Future<void> completeFlexibleUpdate() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      debugPrint('Bestcast InAppUpdate: completeFlexibleUpdate failed: $e');
    }
  }

  static Future<void> _handleUpdate({
    required AppUpdateInfo info,
    required AppUpdateMode mode,
    VoidCallback? onFlexibleUpdateDownloaded,
  }) async {
    bool shouldBeImmediate = false;

    switch (mode) {
      case AppUpdateMode.immediate:
        shouldBeImmediate = true;
        break;
      case AppUpdateMode.flexible:
        shouldBeImmediate = false;
        break;
      case AppUpdateMode.auto:
        // Prioritize immediate update if Google Play priority is high (>=4)
        // or the user's version is stale (>= 7 days).
        final isCritical = (info.updatePriority >= 4) ||
            ((info.clientVersionStalenessDays ?? 0) >= 7);
        shouldBeImmediate = isCritical;
        break;
    }

    if (shouldBeImmediate) {
      if (info.immediateUpdateAllowed) {
        debugPrint('Bestcast InAppUpdate: Starting immediate update');
        await InAppUpdate.performImmediateUpdate();
      } else if (info.flexibleUpdateAllowed) {
        debugPrint('Bestcast InAppUpdate: Immediate not allowed, falling back to flexible');
        final result = await InAppUpdate.startFlexibleUpdate();
        if (result == AppUpdateResult.success) {
          onFlexibleUpdateDownloaded?.call();
        }
      }
    } else {
      if (info.flexibleUpdateAllowed) {
        debugPrint('Bestcast InAppUpdate: Starting flexible update');
        final result = await InAppUpdate.startFlexibleUpdate();
        if (result == AppUpdateResult.success) {
          onFlexibleUpdateDownloaded?.call();
        }
      } else if (info.immediateUpdateAllowed) {
        debugPrint('Bestcast InAppUpdate: Flexible not allowed, falling back to immediate');
        await InAppUpdate.performImmediateUpdate();
      }
    }
  }

  @visibleForTesting
  static void resetForTesting() {
    _isChecking = false;
    _lastCheckTime = null;
  }
}
