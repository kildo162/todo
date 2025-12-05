import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionUser {
  final String displayName;
  final String email;
  final String avatarUrl;
  final String plan;

  const SessionUser({
    required this.displayName,
    required this.email,
    this.avatarUrl = '',
    this.plan = 'Gói tiêu chuẩn',
  });

  SessionUser copyWith({
    String? displayName,
    String? email,
    String? avatarUrl,
    String? plan,
  }) {
    return SessionUser(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      plan: plan ?? this.plan,
    );
  }

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'email': email,
    'avatarUrl': avatarUrl,
    'plan': plan,
  };

  factory SessionUser.fromJson(Map<String, dynamic> json) {
    return SessionUser(
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      plan: json['plan'] as String? ?? 'Gói tiêu chuẩn',
    );
  }
}

class SessionSettings {
  final bool pushEnabled;
  final bool emailDigest;
  final bool darkMode;

  const SessionSettings({
    this.pushEnabled = true,
    this.emailDigest = false,
    this.darkMode = false,
  });

  SessionSettings copyWith({
    bool? pushEnabled,
    bool? emailDigest,
    bool? darkMode,
  }) {
    return SessionSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailDigest: emailDigest ?? this.emailDigest,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  Map<String, dynamic> toJson() => {
    'pushEnabled': pushEnabled,
    'emailDigest': emailDigest,
    'darkMode': darkMode,
  };

  factory SessionSettings.fromJson(Map<String, dynamic> json) {
    return SessionSettings(
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      emailDigest: json['emailDigest'] as bool? ?? false,
      darkMode: json['darkMode'] as bool? ?? false,
    );
  }
}

class SessionController extends GetxController {
  static const _storageKey = 'session_state_v1';

  final isAuthenticated = false.obs;
  final user = Rxn<SessionUser>();
  final settings = const SessionSettings().obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> signIn({
    required SessionUser newUser,
    SessionSettings? newSettings,
  }) async {
    user.value = newUser;
    if (newSettings != null) {
      settings.value = newSettings;
    }
    isAuthenticated.value = true;
    await _save();
  }

  Future<void> signOut() async {
    isAuthenticated.value = false;
    user.value = null;
    await _save();
  }

  Future<void> updateSettings({
    bool? pushEnabled,
    bool? emailDigest,
    bool? darkMode,
  }) async {
    final updated = settings.value.copyWith(
      pushEnabled: pushEnabled,
      emailDigest: emailDigest,
      darkMode: darkMode,
    );
    settings.value = updated;
    await _save();
  }

  Future<void> updateUser(SessionUser updatedUser) async {
    user.value = updatedUser;
    await _save();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      isAuthenticated.value = decoded['authenticated'] as bool? ?? false;
      if (decoded['user'] != null) {
        user.value = SessionUser.fromJson(
          decoded['user'] as Map<String, dynamic>,
        );
      }
      if (decoded['settings'] != null) {
        settings.value = SessionSettings.fromJson(
          decoded['settings'] as Map<String, dynamic>,
        );
      }
    } catch (_) {
      // Ignore corrupted state and fall back to defaults
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'authenticated': isAuthenticated.value,
      'user': user.value?.toJson(),
      'settings': settings.value.toJson(),
    };
    await prefs.setString(_storageKey, jsonEncode(data));
  }
}
