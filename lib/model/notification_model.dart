import 'package:flutter/material.dart';

class NotificationModel {
  final int id;
  final String section;
  final String title;
  final String tag;
  final String description;
  final String time;
  final String icon;
  final Color iconBg;
  bool isUnread;

  NotificationModel({
    required this.id,
    required this.section,
    required this.title,
    required this.tag,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconBg,
    this.isUnread = true,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      section: json['section'] as String,
      title: json['title'] as String,
      tag: json['tag'] as String,
      description: json['description'] as String,
      time: json['time'] as String,
      icon: json['icon'] as String,
      iconBg: Color(int.parse(json['iconBg'].toString())),
      isUnread: json['isUnread'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section': section,
      'title': title,
      'tag': tag,
      'description': description,
      'time': time,
      'icon': icon,
      'iconBg': iconBg.value.toString(),
      'isUnread': isUnread,
    };
  }

  NotificationModel copyWith({bool? isUnread}) {
    return NotificationModel(
      id: id,
      section: section,
      title: title,
      tag: tag,
      description: description,
      time: time,
      icon: icon,
      iconBg: iconBg,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}