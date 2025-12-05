import 'package:get/get.dart';

import 'health_model.dart';

class HealthController extends GetxController {
  final exercises = <HealthExercise>[].obs;
  final selectedCategory = ''.obs; // empty = all

  @override
  void onInit() {
    super.onInit();
    exercises.assignAll(_seedExercises());
  }

  List<HealthExercise> get filteredExercises {
    if (selectedCategory.isEmpty) return exercises;
    return exercises
        .where((e) => e.category == selectedCategory.value)
        .toList();
  }

  void setCategory(String category) {
    if (selectedCategory.value == category) {
      selectedCategory.value = '';
    } else {
      selectedCategory.value = category;
    }
  }

  List<HealthExercise> _seedExercises() {
    return const [
      HealthExercise(
        id: '478',
        title: 'Hít thở 4-7-8',
        description:
            'Kỹ thuật hít sâu giúp thư giãn nhanh, hỗ trợ giảm lo âu và dễ ngủ.',
        steps: [
          'Ngồi hoặc nằm thoải mái, thả lỏng vai.',
          'Hít vào bằng mũi trong 4 giây, bụng phồng lên.',
          'Giữ hơi trong 7 giây, thư giãn cơ mặt và vai.',
          'Thở ra bằng miệng trong 8 giây, phát âm "vù" nhẹ.',
          'Lặp lại 4-8 lần hoặc tới khi thấy dịu lại.',
        ],
        durationSeconds: 60,
        category: 'breathing',
      ),
      HealthExercise(
        id: 'box',
        title: 'Box Breathing 4x4',
        description:
            'Hít - giữ - thở - giữ mỗi pha 4 giây, giúp ổn định nhịp thở và tập trung.',
        steps: [
          'Hít vào bằng mũi 4 giây.',
          'Giữ hơi 4 giây.',
          'Thở ra bằng miệng 4 giây.',
          'Giữ hơi 4 giây, rồi lặp lại 4-6 chu kỳ.',
        ],
        durationSeconds: 90,
        category: 'breathing',
      ),
      HealthExercise(
        id: 'neck',
        title: 'Giãn cơ cổ - vai',
        description: 'Giảm căng cơ cổ và vai khi làm việc lâu với máy tính.',
        steps: [
          'Ngồi thẳng lưng, thả lỏng vai.',
          'Nghiêng đầu sang phải, giữ 10 giây, đổi bên.',
          'Quay đầu vòng tròn chậm 2 vòng mỗi chiều.',
          'Kéo tay phải qua đầu, nhẹ nhàng kéo căng cổ trái 15 giây, đổi bên.',
        ],
        durationSeconds: 120,
        category: 'stretch',
      ),
      HealthExercise(
        id: 'eye',
        title: 'Thư giãn mắt 20-20-20',
        description:
            'Giảm mỏi mắt khi nhìn màn hình, kết hợp chớp mắt và nhìn xa.',
        steps: [
          'Mỗi 20 phút, rời mắt khỏi màn hình.',
          'Nhìn vật cách 6m (20 feet) trong 20 giây.',
          'Chớp mắt chậm 10 lần để làm ẩm giác mạc.',
        ],
        durationSeconds: 40,
        category: 'mindful',
      ),
      HealthExercise(
        id: 'body_scan',
        title: 'Body Scan 5 phút',
        description: 'Quét cơ thể và ghi nhận cảm giác, giúp giảm căng thẳng.',
        steps: [
          'Nằm/Ngồi thoải mái, nhắm mắt, hít sâu 2-3 nhịp.',
          'Chú ý cảm giác ở đầu, trán, hàm, thả lỏng.',
          'Di chuyển sự chú ý xuống cổ, vai, ngực, bụng, lưng.',
          'Tiếp tục xuống hông, đùi, gối, cẳng chân, bàn chân.',
          'Nếu tâm trí xao lãng, nhẹ nhàng đưa lại vào hơi thở.',
        ],
        durationSeconds: 300,
        category: 'mindful',
      ),
      HealthExercise(
        id: 'sun_salute',
        title: 'Chuỗi vươn vai 3 phút',
        description: 'Kéo giãn toàn thân nhẹ nhàng, giúp máu lưu thông.',
        steps: [
          'Đứng thẳng, hai chân rộng bằng vai, hít sâu giơ tay qua đầu.',
          'Vươn người lên cao 2-3 nhịp thở, cảm nhận cột sống kéo dài.',
          'Thở ra, gập người chạm tay xuống gối/ống chân, giữ 10 giây.',
          'Đưa tay chống hông, hít vào nâng ngực nhẹ, mở vai.',
          'Lặp lại chu kỳ vươn - gập - mở 3-4 lần.',
        ],
        durationSeconds: 180,
        category: 'stretch',
      ),
      HealthExercise(
        id: 'wrist',
        title: 'Giãn cổ tay 2 phút',
        description: 'Phục hồi cổ tay sau khi gõ phím/chuột lâu.',
        steps: [
          'Đưa tay phải ra trước, lòng bàn tay hướng lên, tay trái kéo nhẹ ngón tay về phía bạn 15 giây, đổi bên.',
          'Xoay cổ tay theo chiều kim đồng hồ 10 vòng, đổi chiều 10 vòng.',
          'Nắm tay nhẹ, mở ra hết cỡ, lặp lại 10 lần.',
        ],
        durationSeconds: 120,
        category: 'stretch',
      ),
      HealthExercise(
        id: '478_bed',
        title: 'Hít thở trước khi ngủ',
        description: 'Biến thể 4-7-8 nằm ngửa, giúp dễ ngủ hơn.',
        steps: [
          'Nằm thoải mái, một tay đặt lên bụng, một tay lên ngực.',
          'Hít vào 4 giây bằng mũi, cảm nhận bụng nâng tay.',
          'Giữ hơi 7 giây, thả lỏng hàm, vai.',
          'Thở ra 8 giây bằng miệng, môi hơi mím, phát âm “vù”.',
          'Lặp lại 4-6 chu kỳ hoặc tới khi buồn ngủ.',
        ],
        durationSeconds: 90,
        category: 'breathing',
      ),
      HealthExercise(
        id: 'micro_walk',
        title: 'Đi bộ tại chỗ 3 phút',
        description: 'Tăng nhịp tim nhẹ, phá vỡ trạng thái ngồi lâu.',
        steps: [
          'Đứng cách bàn 1 bước, nâng gối cao vừa phải, bước tại chỗ 60 giây.',
          'Chuyển sang bước sang ngang trái-phải 30 giây mỗi bên.',
          'Kết thúc bằng 30 giây bước chậm, hít thở sâu để giảm nhịp tim.',
        ],
        durationSeconds: 180,
        category: 'mindful',
      ),
      HealthExercise(
        id: 'shoulder_roll',
        title: 'Lăn vai mở ngực',
        description: 'Giảm co cứng vai, cải thiện tư thế.',
        steps: [
          'Ngồi/đứng thẳng, thả lỏng hai tay.',
          'Lăn vai về sau chậm rãi 10 lần, tập trung mở ngực.',
          'Lăn vai về trước 10 lần.',
          'Đan tay sau lưng, kéo nhẹ xuống và ra sau, giữ 15 giây.',
        ],
        durationSeconds: 150,
        category: 'stretch',
      ),
      HealthExercise(
        id: 'square_breath',
        title: 'Hít thở vuông 5 phút',
        description: 'Biến thể box breathing, giúp tập trung sâu.',
        steps: [
          'Hít vào 4 giây, tưởng tượng vẽ cạnh đầu tiên của hình vuông.',
          'Giữ hơi 4 giây, vẽ cạnh thứ hai.',
          'Thở ra 4 giây, vẽ cạnh thứ ba.',
          'Giữ hơi 4 giây, vẽ cạnh cuối, lặp lại 6-8 chu kỳ.',
        ],
        durationSeconds: 300,
        category: 'breathing',
      ),
    ];
  }
}
