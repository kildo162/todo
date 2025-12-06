import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/home/event/event_controller.dart';
import 'package:app/home/notification/notification_controller.dart';
import 'package:app/shared/local_notification_service.dart';
import 'package:app/shared/session.dart';
import 'package:app/utils/toast_utils.dart';

class ProfileController extends GetxController {
  final SessionController session = Get.isRegistered<SessionController>()
      ? Get.find<SessionController>()
      : Get.put(SessionController(), permanent: true);
  final NotificationController notificationController =
      Get.isRegistered<NotificationController>()
      ? Get.find<NotificationController>()
      : Get.put(NotificationController());
  final EventController eventController = Get.isRegistered<EventController>()
      ? Get.find<EventController>()
      : Get.put(EventController(), permanent: true);

  SessionUser? get user => session.user.value;
  SessionSettings get settings => session.settings.value;
  RxBool get isAuthenticated => session.isAuthenticated;

  Future<void> togglePush(bool value) =>
      session.updateSettings(pushEnabled: value);

  Future<void> toggleEmailDigest(bool value) =>
      session.updateSettings(emailDigest: value);

  Future<void> toggleDarkMode(bool value) =>
      session.updateSettings(darkMode: value);

  Future<void> updateLanguage(String languageCode) async {
    await session.updateSettings(languageCode: languageCode);
    Get.updateLocale(Locale(languageCode));
    ToastUtils.showToast(
      'Đã chuyển ngôn ngữ: ${languageLabel(languageCode)}',
      backgroundColor: const Color(0xFF2563EB),
    );
  }

  Future<void> savePersonalInfo({
    required String displayName,
    required String email,
    String? plan,
    String? avatarUrl,
  }) async {
    final current =
        session.user.value ?? SessionUser(displayName: '', email: '');
    final trimmedPlan = plan?.trim() ?? '';
    final planToSave = trimmedPlan.isNotEmpty
        ? trimmedPlan
        : (current.plan.isNotEmpty ? current.plan : 'Gói tiêu chuẩn');
    final updated = current.copyWith(
      displayName: displayName,
      email: email,
      plan: planToSave,
      avatarUrl: avatarUrl ?? current.avatarUrl,
    );
    await session.updateUser(updated);
    ToastUtils.showToast(
      'Đã lưu thông tin cá nhân',
      backgroundColor: const Color(0xFF2563EB),
    );
  }

  int get createdEvents => eventController.events.length;

  int get participatedEvents => eventController.pastEvents.length;

  int get unreadNotifications =>
      notificationController.notifications.where((n) => !n.read).length;

  String initials() {
    final name = user?.displayName.trim();
    if (name == null || name.isEmpty) return 'NA';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String languageLabel(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Tiếng Việt';
      case 'ja':
        return '日本語';
      default:
        return 'Tiếng Việt';
    }
  }

  Future<void> logout() async {
    await session.signOut();
    ToastUtils.showToast(
      'Đã đăng xuất',
      backgroundColor: const Color(0xFF374151),
    );
    Get.offAllNamed('/login');
  }

  Future<void> sendTestNotification() async {
    final name = user?.displayName.isNotEmpty == true
        ? user!.displayName
        : 'bạn';
    notificationController.addTestNotification(
      title: 'Thông báo thử',
      body: 'Xin chào $name, đây là thông báo thử của ứng dụng.',
    );
    await LocalNotificationService.instance.showNotification(
      title: 'Thông báo thử',
      body: 'Xin chào $name, đây là thông báo thử của ứng dụng.',
    );
    ToastUtils.showToast(
      'Đã gửi thông báo thử',
      backgroundColor: const Color(0xFF2563EB),
    );
  }
}
