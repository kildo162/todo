import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/sutra/sutra_models.dart';

class SutraController extends GetxController {
  static const String _chantKey = 'sutra_chant_counts_v1';
  static const String _favoriteKey = 'sutra_favorites_v1';
  static const String _completedKey = 'sutra_completed_v1';
  static const String _historyKey = 'sutra_history_v1';

  final items = <SutraItem>[].obs;
  final chantCounts = <String, int>{}.obs;
  final favoriteIds = <String>{}.obs;
  final completedIds = <String>{}.obs;
  final history = <SutraHistoryEntry>[].obs;
  final RxString searchQuery = ''.obs;
  final RxSet<SutraCategory> activeCategories = <SutraCategory>{}.obs;
  final RxBool compactMode = false.obs;
  final RxString sortKey = 'default'.obs; // default, recent, duration, title
  final RxBool favoritesOnly = false.obs;
  final RxBool completedOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    items.assignAll(_defaultItems());
    _loadState();
  }

  List<SutraItem> get chantingItems => items.where((e) => e.category == SutraCategory.chant).toList();

  List<SutraItem> get scriptureItems => items.where((e) => e.category == SutraCategory.scripture).toList();

  List<SutraItem> get lessonItems => items.where((e) => e.category == SutraCategory.lesson).toList();

  List<SutraItem> get favoriteItems => items.where((e) => favoriteIds.contains(e.id)).toList();

  int get totalChantCount => chantCounts.values.fold(0, (a, b) => a + b);

  int get completedLessons => completedIds.length;

  List<SutraHistoryEntry> get recentHistory {
    final list = [...history]..sort((a, b) => b.time.compareTo(a.time));
    return list.take(50).toList();
  }

  List<SutraItem> get filteredItems {
    Iterable<SutraItem> current = items;

    if (activeCategories.isNotEmpty) {
      current = current.where((e) => activeCategories.contains(e.category));
    }

    if (favoritesOnly.value) {
      current = current.where((e) => favoriteIds.contains(e.id));
    }

    if (completedOnly.value) {
      current = current.where((e) => completedIds.contains(e.id));
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      current = current.where(
        (e) =>
            e.title.toLowerCase().contains(query) ||
            e.description.toLowerCase().contains(query) ||
            e.tags.any((t) => t.toLowerCase().contains(query)),
      );
    }

    final list = current.toList();
    switch (sortKey.value) {
      case 'recent':
        list.sort((a, b) {
          final lastA = _lastHistoryTime(a.id);
          final lastB = _lastHistoryTime(b.id);
          return (lastB ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(lastA ?? DateTime.fromMillisecondsSinceEpoch(0));
        });
        break;
      case 'duration':
        list.sort((a, b) => (a.durationMinutes ?? 999).compareTo(b.durationMinutes ?? 999));
        break;
      case 'title':
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
      default:
        break;
    }
    return list;
  }

  DateTime? _lastHistoryTime(String itemId) {
    for (final h in history) {
      if (h.itemId == itemId) return h.time;
    }
    return null;
  }

  SutraItem? findById(String id) {
    try {
      return items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  int chantCountFor(String id) => chantCounts[id] ?? 0;

  double chantProgress(String id) {
    final item = findById(id);
    if (item == null || item.targetCount == null || item.targetCount == 0) return 0;
    final value = chantCountFor(id) / item.targetCount!;
    return value.clamp(0, 1);
  }

  bool isFavorite(String id) => favoriteIds.contains(id);

  bool isCompleted(String id) => completedIds.contains(id);

  Future<void> incrementChant(String id, {int delta = 1}) async {
    final current = chantCountFor(id);
    chantCounts[id] = current + delta;
    chantCounts.refresh();
    _addHistoryEntry(type: SutraActionType.chant, itemId: id, count: delta);
    await _saveState();
  }

  Future<void> toggleFavorite(String id) async {
    if (favoriteIds.contains(id)) {
      favoriteIds.remove(id);
    } else {
      favoriteIds.add(id);
    }
    favoriteIds.refresh();
    await _saveState();
  }

  Future<void> toggleCompleted(String id) async {
    if (completedIds.contains(id)) {
      completedIds.remove(id);
    } else {
      completedIds.add(id);
      _addHistoryEntry(type: SutraActionType.complete, itemId: id, count: 1);
    }
    completedIds.refresh();
    await _saveState();
  }

  Future<void> logReading(String id, {int? durationMinutes}) async {
    _addHistoryEntry(type: SutraActionType.read, itemId: id, durationMinutes: durationMinutes);
    await _saveState();
  }

  Future<void> resetChantCounts() async {
    chantCounts.clear();
    await _saveState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final rawChants = prefs.getString(_chantKey);
    if (rawChants != null && rawChants.isNotEmpty) {
      final decoded = jsonDecode(rawChants) as Map<String, dynamic>;
      chantCounts.assignAll(decoded.map((key, value) => MapEntry(key, (value as num).toInt())));
    }

    final rawFavorites = prefs.getStringList(_favoriteKey);
    if (rawFavorites != null) {
      favoriteIds.addAll(rawFavorites);
    }

    final rawCompleted = prefs.getStringList(_completedKey);
    if (rawCompleted != null) {
      completedIds.addAll(rawCompleted);
    }

    final rawHistory = prefs.getString(_historyKey);
    if (rawHistory != null && rawHistory.isNotEmpty) {
      final decoded = jsonDecode(rawHistory) as List<dynamic>;
      history.assignAll(decoded.map((e) => SutraHistoryEntry.fromJson(e as Map<String, dynamic>)).toList());
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chantKey, jsonEncode(chantCounts));
    await prefs.setStringList(_favoriteKey, favoriteIds.toList());
    await prefs.setStringList(_completedKey, completedIds.toList());
    await prefs.setString(_historyKey, jsonEncode(history.map((e) => e.toJson()).toList()));
  }

  void _addHistoryEntry({
    required SutraActionType type,
    required String itemId,
    int count = 1,
    int? durationMinutes,
  }) {
    final entry = SutraHistoryEntry(
      id: '${itemId}_${DateTime.now().millisecondsSinceEpoch}',
      itemId: itemId,
      type: type,
      time: DateTime.now(),
      count: count,
      durationMinutes: durationMinutes,
    );
    history.insert(0, entry);
    if (history.length > 200) {
      history.removeRange(200, history.length);
    }
    history.refresh();
  }

  List<SutraItem> _defaultItems() {
    return const [
      SutraItem(
        id: 'amitabha',
        category: SutraCategory.chant,
        title: 'Kinh A Di Đà',
        description: 'Quán niệm Phật A Di Đà, nuôi dưỡng niềm tin Tịnh độ.',
        content:
            'Xưng niệm Nam Mô A Di Đà Phật, quán tưởng cõi Tịnh độ, phát tâm bồ đề và hồi hướng chúng sinh.',
        targetCount: 21,
        durationMinutes: 25,
        tags: ['Tịnh độ', 'Buổi tối'],
      ),
      SutraItem(
        id: 'dai_bi',
        category: SutraCategory.chant,
        title: 'Chú Đại Bi',
        description: 'Trợ duyên phát khởi tâm từ bi, giải trừ nghiệp chướng.',
        content:
            'Thiên thủ thiên nhãn vô ngại đại bi tâm đà la ni... (trì tụng đủ bài, giữ tâm chánh niệm).',
        targetCount: 21,
        durationMinutes: 30,
        tags: ['Từ bi', 'Hộ trì'],
      ),
      SutraItem(
        id: 'lang_nghiem',
        category: SutraCategory.chant,
        title: 'Chú Lăng Nghiêm',
        description: 'An trụ tâm, hộ trì đạo tràng, tăng trưởng định lực.',
        content: 'Nam Mô Tát Đát Tha Tát Đa... (trì tụng nghiêm tĩnh, giữ giới thân khẩu ý).',
        targetCount: 7,
        durationMinutes: 35,
        tags: ['Định lực', 'Buổi sáng'],
      ),
      SutraItem(
        id: 'duoc_su',
        category: SutraCategory.chant,
        title: 'Kinh Dược Sư',
        description: 'Cầu an, cầu tiêu tai bệnh tật, nuôi dưỡng tâm an lạc.',
        content:
            'Quán tưởng Đức Phật Dược Sư và mười hai Dược Xoa hộ pháp, phát nguyện lợi ích hữu tình.',
        targetCount: 7,
        durationMinutes: 28,
        tags: ['Cầu an', 'Trì tụng'],
      ),
      SutraItem(
        id: 'sam_hoi',
        category: SutraCategory.chant,
        title: 'Sám hối Hồng danh',
        description: 'Lạy danh hiệu chư Phật, sám trừ nghiệp chướng, làm mới thân tâm.',
        content:
            'Danh hiệu 89 hoặc 108 vị Phật; phát lồ sám hối, phát nguyện tu tập thiện pháp, chuyển hóa nghiệp xấu.',
        targetCount: 3,
        durationMinutes: 20,
        tags: ['Sám hối', 'Thanh lọc'],
      ),
      SutraItem(
        id: 'pho_mon',
        category: SutraCategory.scripture,
        title: 'Kinh Pháp Hoa - Phẩm Phổ Môn',
        description: 'Quán Thế Âm lắng nghe tiếng khổ, nuôi dưỡng tâm từ bi cứu giúp.',
        content:
            'Nếu có chúng sinh chịu khổ não, một lòng xưng danh Bồ Tát Quán Thế Âm tức đặng giải thoát...',
        durationMinutes: 18,
        tags: ['Pháp Hoa', 'Từ bi'],
      ),
      SutraItem(
        id: 'kim_cang',
        category: SutraCategory.scripture,
        title: 'Kinh Kim Cang',
        description: 'Quán chiếu vô ngã, phá chấp tướng để đạt trí tuệ Bát Nhã.',
        content:
            'Phàm sở hữu tướng giai thị hư vọng, nhược kiến chư tướng phi tướng tức kiến Như Lai.',
        durationMinutes: 22,
        tags: ['Bát Nhã', 'Vô ngã'],
      ),
      SutraItem(
        id: 'bat_nha',
        category: SutraCategory.scripture,
        title: 'Bát Nhã Tâm Kinh',
        description: 'Tinh yếu Bát Nhã, soi tỏ năm uẩn đều không.',
        content:
            'Quán Tự Tại Bồ Tát, hành thâm Bát Nhã Ba La Mật Đa thời chiếu kiến ngũ uẩn giai không...',
        durationMinutes: 8,
        tags: ['Ngắn', 'Thiền quán'],
      ),
      SutraItem(
        id: 'dia_tang',
        category: SutraCategory.scripture,
        title: 'Kinh Địa Tạng',
        description: 'Nương sức Đại nguyện Địa Tạng Bồ Tát, khởi tâm hiếu kính và cứu độ.',
        content:
            'Phát tâm hiếu thuận cha mẹ, hộ trì người mất, nguyện làm các thiện hạnh để giải trừ nghiệp chướng.',
        durationMinutes: 30,
        tags: ['Hiếu hạnh', 'Cầu siêu'],
      ),
      SutraItem(
        id: 'vu_lan',
        category: SutraCategory.scripture,
        title: 'Kinh Vu Lan Báo Hiếu',
        description: 'Quán niệm hiếu đạo theo gương Mục Kiền Liên cứu mẹ.',
        content:
            'Nhớ ân sinh thành dưỡng dục, thực hành cúng dường và làm phước hồi hướng cha mẹ hiện tiền và quá vãng.',
        durationMinutes: 18,
        tags: ['Hiếu', 'Cầu an'],
      ),
      SutraItem(
        id: 'phap_cu',
        category: SutraCategory.scripture,
        title: 'Kinh Pháp Cú',
        description: 'Lời dạy tinh tuyển của Đức Phật về đạo đức, thiền định, trí tuệ.',
        content:
            'Các kệ tụng ngắn gọn, soi sáng cách sống chánh niệm, buông bỏ tham sân si và nuôi dưỡng từ bi.',
        durationMinutes: 15,
        tags: ['Kệ', 'Tóm lược'],
      ),
      SutraItem(
        id: 'diu_phap_lien_hoa',
        category: SutraCategory.scripture,
        title: 'Kinh Diệu Pháp Liên Hoa',
        description: 'Tán thán trí tuệ Như Lai, khơi mở niềm tin Bồ Tát đạo.',
        content:
            'Học tinh thần nhất thừa, thấy mọi loài đều có Phật tính, khích lệ tu tập Bồ Tát hạnh giữa đời.',
        durationMinutes: 25,
        tags: ['Niềm tin', 'Bồ Tát đạo'],
      ),
      SutraItem(
        id: 'ngu_gioi',
        category: SutraCategory.lesson,
        title: 'Ngũ Giới',
        description: 'Nền tảng đạo đức: không sát sinh, trộm cắp, tà hạnh, vọng ngữ, uống rượu.',
        content:
            'Thực tập ngũ giới để bảo hộ thân tâm, nuôi dưỡng hiểu biết và thương yêu trong đời sống hàng ngày.',
        tags: ['Giới luật', 'Cơ bản'],
        level: 'Nền tảng',
      ),
      SutraItem(
        id: 'tu_dieu_de',
        category: SutraCategory.lesson,
        title: 'Tứ Diệu Đế',
        description: 'Khổ, Tập, Diệt, Đạo - con đường chuyển hóa khổ đau.',
        content:
            'Quán chiếu bản chất khổ, nhận diện nguyên nhân, tin vào khả năng diệt khổ và thực tập Bát Chánh Đạo.',
        tags: ['Cơ bản', 'Quán chiếu'],
        level: 'Cơ bản',
      ),
      SutraItem(
        id: 'bat_chanh_dao',
        category: SutraCategory.lesson,
        title: 'Bát Chánh Đạo',
        description: 'Chánh kiến, tư duy, ngữ, nghiệp, mạng, tinh tấn, niệm, định.',
        content:
            'Tám chi phần nâng đỡ nhau: hiểu đúng, nghĩ đúng, nói đúng, làm đúng, sống đúng, tinh tấn, chánh niệm, tập trung.',
        tags: ['Hành trì', 'Đường tu'],
        level: 'Cơ bản',
      ),
      SutraItem(
        id: 'luc_do',
        category: SutraCategory.lesson,
        title: 'Lục Độ Ba La Mật',
        description: 'Bố thí, trì giới, nhẫn nhục, tinh tấn, thiền định, trí tuệ.',
        content:
            'Sáu phép vượt bờ sinh tử, thực tập song song để lợi mình lợi người, nuôi dưỡng Bồ Tát hạnh.',
        tags: ['Bồ Tát hạnh'],
        level: 'Trung cấp',
      ),
      SutraItem(
        id: 'tu_vo_luong_tam',
        category: SutraCategory.lesson,
        title: 'Tứ Vô Lượng Tâm',
        description: 'Từ, Bi, Hỷ, Xả - mở rộng trái tim không biên giới.',
        content:
            'Thực tập thương yêu, cảm thông, vui theo và buông xả; ôm ấp bản thân và người khác bằng hiểu biết.',
        tags: ['Thiền tâm từ'],
        level: 'Cơ bản',
      ),
    ];
  }
}
