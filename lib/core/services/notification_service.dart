import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../domain/entities/timer_session.dart';

enum NotificationAction {
  pause,
  resume,
  reset,
  tap,
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Use a stream controller to broadcast notification actions
  final _actionController = StreamController<NotificationAction>.broadcast();
  Stream<NotificationAction> get actionStream => _actionController.stream;

  Future<void> initialize() async {
    if (kIsWeb || _isInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        _handleNotificationResponse(details);
      },
      onDidReceiveBackgroundNotificationResponse:
          _handleNotificationResponseBackground,
    );

    // Request notification permission on Android 13+ (API 33+)
    // This is required for notifications to show on newer Android versions
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _isInitialized = true;
  }

  void _handleNotificationResponse(NotificationResponse details) {
    if (details.actionId == 'pause') {
      _actionController.add(NotificationAction.pause);
    } else if (details.actionId == 'resume') {
      _actionController.add(NotificationAction.resume);
    } else if (details.actionId == 'reset') {
      _actionController.add(NotificationAction.reset);
    } else {
      _actionController.add(NotificationAction.tap);
    }
  }

  @pragma('vm:entry-point')
  static void _handleNotificationResponseBackground(
      NotificationResponse details) {
    final instance = NotificationService();
    if (details.actionId == 'pause') {
      instance._actionController.add(NotificationAction.pause);
    } else if (details.actionId == 'resume') {
      instance._actionController.add(NotificationAction.resume);
    } else if (details.actionId == 'reset') {
      instance._actionController.add(NotificationAction.reset);
    } else {
      instance._actionController.add(NotificationAction.tap);
    }
  }

  Future<void> showTimerNotification({
    required String title,
    required String body,
    required TimerType timerType,
    required String timeRemaining,
    required bool isRunning,
  }) async {
    if (kIsWeb) return;
    await initialize();

    // NOTE: Action buttons removed (pause/reset) because they were unreliable
    // when the app is backgrounded. The notification will now show only the
    // timer text. If native action handling is added later, re-introduce
    // pending intents on the Android side.
    const androidDetails = AndroidNotificationDetails(
      'zenflow_timer',
      'Timer',
      channelDescription: 'Pomodoro timer notifications',
      importance:
          Importance.low, // Low importance = no heads-up, stays in shade only
      priority: Priority.low, // Low priority = no popup
      ongoing: true, // Can't be dismissed, persistent
      autoCancel: false,
      onlyAlertOnce: true, // No sound/vibration on updates
      showWhen: false,
      icon: '@mipmap/ic_launcher',
      category: AndroidNotificationCategory
          .progress, // Changed from alarm to progress
      silent: true, // No sound
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0, // Notification ID (0 for persistent timer notification)
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> updateTimerNotification({
    required String timeRemaining,
    required TimerType timerType,
    required bool isRunning,
  }) async {
    String title;
    switch (timerType) {
      case TimerType.focus:
        title = '🎯 Focus Time';
        break;
      case TimerType.shortBreak:
        title = '☕ Short Break';
        break;
      case TimerType.longBreak:
        title = '🌴 Long Break';
        break;
    }

    await showTimerNotification(
      title: title,
      body: timeRemaining,
      timerType: timerType,
      timeRemaining: timeRemaining,
      isRunning: isRunning,
    );
  }

  Future<void> showCompletionNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'zenflow_completion',
      'Timer Completion',
      channelDescription: 'Timer completion notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.alarm,
      // Removed fullScreenIntent to allow swipe-to-dismiss (left/right)
      // Using heads-up notification instead (importance.max) which shows
      // prominently but allows normal dismiss gestures
      onlyAlertOnce: false, // Allow sound/vibration each time
      autoCancel: true, // Auto-dismiss when tapped
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use unique ID based on timestamp to prevent re-showing after dismiss
    // This ensures each completion notification is truly independent
    final uniqueId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _notifications.show(
      uniqueId, // Unique ID for each completion notification
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> cancelTimerNotification() async {
    if (kIsWeb) return;
    await _notifications.cancel(0);
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _notifications.cancelAll();
  }

  void dispose() {
    _actionController.close();
  }
}
