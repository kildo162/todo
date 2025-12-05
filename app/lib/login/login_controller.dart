import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/utils/toast_utils.dart';
import 'package:app/shared/session.dart';

class LoginController extends GetxController {
  // FIXME: POC default credentials to skip manual input on login
  static const String _pocDefaultEmail = 'admin';
  static const String _pocDefaultPassword = 'admin';

  final TextEditingController emailController = TextEditingController(text: _pocDefaultEmail);
  final TextEditingController passwordController = TextEditingController(text: _pocDefaultPassword);

  var email = _pocDefaultEmail.obs;
  var password = _pocDefaultPassword.obs;
  var isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (isLoading.value) return;

    final emailValue = emailController.text.trim();
    final passwordValue = passwordController.text.trim();
    email.value = emailValue;
    password.value = passwordValue;

    if (emailValue.isEmpty || passwordValue.isEmpty) {
      ToastUtils.showToast('Vui lòng nhập đầy đủ thông tin', backgroundColor: Colors.orange);
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 900)); // Mock request

    if (emailValue == 'admin' && passwordValue == 'admin') {
      final session = Get.isRegistered<SessionController>()
          ? Get.find<SessionController>()
          : Get.put(SessionController(), permanent: true);
      await session.signIn(
        newUser: SessionUser(
          displayName: 'Quản trị viên',
          email: emailValue,
          plan: 'Premium',
        ),
      );
      ToastUtils.showToast('Đăng nhập thành công', backgroundColor: Colors.green);
      Get.offAllNamed('/home');
    } else {
      ToastUtils.showToast('Thông tin đăng nhập chưa chính xác (mock)', backgroundColor: Colors.red);
    }
    isLoading.value = false;
  }
}
