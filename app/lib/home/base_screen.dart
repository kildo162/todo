import 'package:flutter/material.dart' hide TabController;
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:app/home/tab_controller.dart';
import 'package:app/home/home/home_screen.dart';
import 'package:app/home/event/event_screen.dart';
import 'package:app/home/notification/notification_screen.dart';
import 'package:app/home/profile/profile_screen.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final TabController controller = Get.put(TabController());
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeTabScreen(),
    EventTabScreen(),
    NotificationTabScreen(),
    ProfileTabScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildTabItem(int index, String outlineIcon, String solidIcon, String label) {
    return Expanded(
      child: InkWell(
        onTap: () => _onTabSelected(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              _selectedIndex == index ? solidIcon : outlineIcon,
              height: 24,
              colorFilter: ColorFilter.mode(_selectedIndex == index ? Colors.blue : Colors.grey, BlendMode.srcIn),
            ),
            SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _selectedIndex == index ? Colors.blue : Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(bottom: 0), // Add extra space for FAB and BottomAppBar
        child: _screens[_selectedIndex],
      ),
      floatingActionButton: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: RawMaterialButton(
          shape: CircleBorder(),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Quick Action'),
                content: Text('Add something quickly!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Close'),
                  ),
                ],
              ),
            );
          },
          elevation: 0,
          fillColor: Colors.transparent,
          child: Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(0, 'icons/outline/home.svg', 'icons/solid/home.svg', 'Home'),
              _buildTabItem(1, 'icons/outline/calendar.svg', 'icons/solid/calendar.svg', 'Event'),
              SizedBox(width: 60), // Space for bigger FAB
              _buildTabItem(2, 'icons/outline/bell.svg', 'icons/solid/bell.svg', 'Notification'),
              _buildTabItem(3, 'icons/outline/user.svg', 'icons/solid/user.svg', 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
