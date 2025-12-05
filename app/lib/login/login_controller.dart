import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/utils/toast_utils.dart';

class LoginController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;

  Future<void> login() async {
    if (isLoading.value) return;

    final emailValue = email.value.trim();
    final passwordValue = password.value.trim();

    if (emailValue.isEmpty || passwordValue.isEmpty) {
      ToastUtils.showToast('Vui lòng nhập đầy đủ thông tin', backgroundColor: Colors.orange);
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 900)); // Mock request

    if (emailValue == 'admin' && passwordValue == 'admin') {
      ToastUtils.showToast('Đăng nhập thành công', backgroundColor: Colors.green);
      Get.offAllNamed('/home');
    } else {
      ToastUtils.showToast('Thông tin đăng nhập chưa chính xác (mock)', backgroundColor: Colors.red);
    }
    isLoading.value = false;
  }
}
