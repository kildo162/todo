import 'package:flutter/material.dart';

enum SutraCategory { chant, scripture, lesson }

enum SutraActionType { chant, read, complete }

extension SutraCategoryLabel on SutraCategory {
  String get label {
    switch (this) {
      case SutraCategory.chant:
        return 'Tụng kinh · Trì chú';
      case SutraCategory.scripture:
        return 'Kinh kệ';
      case SutraCategory.lesson:
        return 'Phật pháp cơ bản';
    }
  }

  Color get color {
    switch (this) {
      case SutraCategory.chant:
        return const Color(0xFF2563EB);
      case SutraCategory.scripture:
        return const Color(0xFF7E57C2);
      case SutraCategory.lesson:
        return const Color(0xFF16A34A);
    }
  }
}

extension SutraActionLabel on SutraActionType {
  String get label {
    switch (this) {
      case SutraActionType.chant:
        return 'Tụng kinh';
      case SutraActionType.read:
        return 'Đọc kinh';
      case SutraActionType.complete:
        return 'Hoàn thành bài học';
    }
  }

  Color get color {
    switch (this) {
      case SutraActionType.chant:
        return const Color(0xFF2563EB);
      case SutraActionType.read:
        return const Color(0xFF7E57C2);
      case SutraActionType.complete:
        return const Color(0xFF16A34A);
    }
  }
}

class SutraItem {
  final String id;
  final SutraCategory category;
  final String title;
  final String description;
  final String content;
  final List<String> tags;
  final int? targetCount; // Số biến/hiệp tụng gợi ý
  final int? durationMinutes; // Thời lượng đọc/thiền gợi ý
  final String level; // cơ bản/nâng cao

  const SutraItem({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.content,
    this.tags = const [],
    this.targetCount,
    this.durationMinutes,
    this.level = 'Cơ bản',
  });
}

class SutraHistoryEntry {
  final String id;
  final String itemId;
  final SutraActionType type;
  final DateTime time;
  final int count;
  final int? durationMinutes;

  const SutraHistoryEntry({
    required this.id,
    required this.itemId,
    required this.type,
    required this.time,
    this.count = 1,
    this.durationMinutes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemId': itemId,
    'type': type.name,
    'time': time.toIso8601String(),
    'count': count,
    'durationMinutes': durationMinutes,
  };

  factory SutraHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SutraHistoryEntry(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      type: SutraActionType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'chant'),
        orElse: () => SutraActionType.chant,
      ),
      time: DateTime.parse(json['time'] as String),
      count: (json['count'] as num?)?.toInt() ?? 1,
      durationMinutes: json['durationMinutes'] as int?,
    );
  }
}
