import 'package:get/get.dart';
import 'notification_model.dart';

class NotificationController extends GetxController {
  var notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    notifications.value = [
      NotificationModel(
        title: 'Welcome!',
        body: 'Thanks for joining our app.',
        read: true,
        time: DateTime.now().subtract(Duration(minutes: 5)),
      ),
      NotificationModel(
        title: 'Update Available',
        body: 'Version 2.0 is now live.',
        read: false,
        time: DateTime.now().subtract(Duration(hours: 1)),
      ),
      NotificationModel(
        title: 'Event Reminder',
        body: 'Don’t forget the meeting at 3PM.',
        read: false,
        time: DateTime.now().subtract(Duration(days: 1)),
      ),
      NotificationModel(
        title: 'Promotion',
        body: 'Get 20% off on your next purchase.',
        read: true,
        time: DateTime.now().subtract(Duration(minutes: 30)),
      ),
      NotificationModel(
        title: 'System Maintenance',
        body: 'Scheduled maintenance at midnight.',
        read: false,
        time: DateTime.now().subtract(Duration(hours: 2)),
      ),
      NotificationModel(
        title: 'New Message',
        body: 'You have received a new message.',
        read: false,
        time: DateTime.now().subtract(Duration(minutes: 10)),
      ),
      NotificationModel(
        title: 'Friend Request',
        body: 'John Doe sent you a friend request.',
        read: true,
        time: DateTime.now().subtract(Duration(hours: 3)),
      ),
      NotificationModel(
        title: 'Security Alert',
        body: 'Unusual login detected.',
        read: false,
        time: DateTime.now().subtract(Duration(minutes: 2)),
      ),
      NotificationModel(
        title: 'Survey',
        body: 'Please take our quick survey.',
        read: true,
        time: DateTime.now().subtract(Duration(days: 2)),
      ),
      NotificationModel(
        title: 'App Tips',
        body: 'Check out new features in settings.',
        read: false,
        time: DateTime.now().subtract(Duration(hours: 5)),
      ),
    ];
  }

  Future<void> fetchNotifications() async {
    await Future.delayed(Duration(seconds: 1));
    // Add new mock notification for demo
    notifications.insert(0, NotificationModel(
      title: 'Pulled Notification',
      body: 'This notification was fetched by pull-to-refresh.',
      read: false,
      time: DateTime.now(),
    ));
  }

  void markAllAsRead() {
    notifications.value = notifications.map((n) => n.copyWith(read: true)).toList();
  }
}
