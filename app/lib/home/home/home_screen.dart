import 'package:app/home/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeTabScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text('Home', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Home', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Spacer(),
            SizedBox(height: 80), // Space for FAB & BottomBar
          ],
        ),
      ),
    );
  }
}
