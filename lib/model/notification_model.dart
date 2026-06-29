class NotificationModel {
  final String id;
  final String title;
  final String desc;
  final String time;
  final String day;
  final String badge;
  final String icon;
  bool unread;

  NotificationModel({
    required String id,
    required this.title,
    required this.desc,
    required this.time,
    required this.day,
    required this.badge,
    required this.icon,
    this.unread = true,
  }) : id = id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : id;

  NotificationModel copyWith({bool? unread}) {
    return NotificationModel(
      id: id,
      title: title,
      desc: desc,
      time: time,
      day: day,
      badge: badge,
      icon: icon,
      unread: unread ?? this.unread,
    );
  }
}