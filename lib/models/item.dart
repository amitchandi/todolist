// ignore_for_file: file_names

import 'package:uuid/uuid.dart';

import 'package:todo/models/reminder.dart';
import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  String id = const Uuid().v4().toString();
  String title;
  String detail;
  bool isChecked;
  String dueDate = '';
  int dueDateNotifId = -1;
  List<Reminder> reminders = [];

  Item(
      {required this.id,
      required this.title,
      required this.detail,
      required this.isChecked,
      required this.dueDate,
      required this.dueDateNotifId,
      required this.reminders});

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);

  @override
  String toString() {
    return '{id: $id, title: $title, detail: $detail, isChecked: $isChecked, dueDate: $dueDate, reminders: $reminders}';
  }
}
