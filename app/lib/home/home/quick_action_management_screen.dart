import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class QuickActionManagementScreen extends StatelessWidget {
  QuickActionManagementScreen({super.key});

  final HomeController controller = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý lối tắt'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700),
        actions: [
          TextButton(
            onPressed: controller.resetActions,
            child: const Text('Mặc định', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700)),
          )
        ],
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: Obx(() {
        final actions = controller.quickActions;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Kéo để sắp xếp, bật/tắt để ẩn lối tắt trên Trang chủ.', style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 6),
                    Text('Các thay đổi được lưu cục bộ (mock).', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: actions.length,
                  onReorder: controller.reorderActions,
                  padding: EdgeInsets.zero,
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(12),
                      child: child,
                    );
                  },
                  itemBuilder: (context, index) {
                    final item = actions[index];
                    return Container(
                      key: ValueKey(item.id),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                            child: Icon(Icons.drag_indicator, color: Colors.blue.shade600),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(item.id, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                              ],
                            ),
                          ),
                          Switch(
                            value: item.enabled,
                            onChanged: (v) => controller.toggleAction(item.id, v),
                            activeColor: Colors.white,
                            activeTrackColor: Colors.blue.shade600,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
