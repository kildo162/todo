class NotificationModel {
  final String title;
  final String body;
  final bool read;
  final DateTime time;

  NotificationModel({
    required this.title,
    required this.body,
    required this.read,
    required this.time,
  });

  NotificationModel copyWith({
    String? title,
    String? body,
    bool? read,
    DateTime? time,
  }) {
    return NotificationModel(
      title: title ?? this.title,
      body: body ?? this.body,
      read: read ?? this.read,
      time: time ?? this.time,
    );
  }
}
