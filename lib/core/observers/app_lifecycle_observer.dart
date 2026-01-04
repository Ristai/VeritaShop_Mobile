import 'package:flutter/material.dart';

/// Observer theo dõi app lifecycle để lock PIN khi cần
/// Khi app vào background > threshold thì sẽ yêu cầu PIN
class AppLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResumedFromBackground;
  final VoidCallback? onPaused;

  DateTime? _pausedAt;
  final Duration backgroundThreshold;

  AppLifecycleObserver({
    required this.onResumedFromBackground,
    this.onPaused,
    this.backgroundThreshold = const Duration(seconds: 30),
  });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        if (_pausedAt == null) {
          _pausedAt = DateTime.now();
          onPaused?.call();
        }
        break;

      case AppLifecycleState.resumed:
        if (_pausedAt != null) {
          final backgroundDuration = DateTime.now().difference(_pausedAt!);
          debugPrint('App was in background for: ${backgroundDuration.inSeconds}s');

          if (backgroundDuration >= backgroundThreshold) {
            onResumedFromBackground();
          }
        }
        _pausedAt = null;
        break;

      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App is being closed or hidden
        break;
    }
  }

  /// Reset pause time (useful when user just verified PIN)
  void resetPauseTime() {
    _pausedAt = null;
  }
}
