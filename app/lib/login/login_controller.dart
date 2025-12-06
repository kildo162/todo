import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:app/utils/toast_utils.dart';
import 'package:app/shared/session.dart';
import 'package:app/services/api_client.dart';
// import 'package:app/services/api_config.dart';

class LoginController extends GetxController {
  // FIXME: POC default credentials to skip manual input on login
  static const String _pocDefaultEmail = 'admin@local';
  static const String _pocDefaultPassword = 'admin';

  final TextEditingController emailController = TextEditingController(
    text: _pocDefaultEmail,
  );
  final TextEditingController passwordController = TextEditingController(
    text: _pocDefaultPassword,
  );

  var email = _pocDefaultEmail.obs;
  var password = _pocDefaultPassword.obs;
  var isLoading = false.obs;
  late final ApiClient apiClient;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    // Use global ApiClient if registered
    try {
      apiClient = Get.find<ApiClient>();
    } catch (e) {
      apiClient = ApiClient();
    }
  }

  Future<void> login() async {
    if (isLoading.value) return;

    final emailValue = emailController.text.trim();
    final passwordValue = passwordController.text.trim();
    email.value = emailValue;
    password.value = passwordValue;

    if (emailValue.isEmpty || passwordValue.isEmpty) {
      ToastUtils.showToast(
        'Vui lòng nhập đầy đủ thông tin',
        backgroundColor: Colors.orange,
      );
      return;
    }

    isLoading.value = true;
    try {
      final body = jsonEncode({"email": emailValue, "password": passwordValue});
      final resp = await apiClient.post(
        '/auth/login',
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final token = data['token'] as String?;
        final user = data['user'] as Map<String, dynamic>?;
        if (user != null) {
          final session = Get.isRegistered<SessionController>()
              ? Get.find<SessionController>()
              : Get.put(SessionController(), permanent: true);
          await session.signIn(
            newUser: SessionUser(
              displayName:
                  (user['full_name'] as String?) ??
                  (user['email'] as String? ?? ""),
              email: (user['email'] as String?) ?? '',
              plan: 'Premium',
            ),
            token: token,
          );
          // Save token in ApiClient for further authenticated requests
          apiClient.setAuthToken(token);
          ToastUtils.showToast(
            'Đăng nhập thành công',
            backgroundColor: Colors.green,
          );
          Get.offAllNamed('/home');
        } else {
          ToastUtils.showToast(
            'Invalid server response',
            backgroundColor: Colors.red,
          );
        }
      } else {
        String message = 'Đăng nhập thất bại';
        try {
          final body = jsonDecode(resp.body);
          if (body is Map && body['error'] != null) message = body['error'];
        } catch (_) {}
        ToastUtils.showToast(message, backgroundColor: Colors.red);
      }
    } catch (err) {
      ToastUtils.showToast('Lỗi kết nối: $err', backgroundColor: Colors.orange);
    }
    isLoading.value = false;
  }
}
