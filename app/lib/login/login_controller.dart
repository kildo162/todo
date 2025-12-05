import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/utils/toast_utils.dart';

class LoginController extends GetxController {
  var email = 'admin'.obs;
  var password = 'admin'.obs;

  void login() {
    if (email.value == 'admin' && password.value == 'admin') {
      ToastUtils.showToast('Logged in successfully', backgroundColor: Colors.green);
      Get.offAllNamed('/home');
    } else {
      ToastUtils.showToast('Invalid credentials', backgroundColor: Colors.red);
    }
  }
}
