// ignore_for_file: file_names

import 'package:json_annotation/json_annotation.dart';

part 'reminder.g.dart';

@JsonSerializable()
class Reminder {
  String dt;
  int notifId;

  Reminder({required this.dt, required this.notifId});

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);

  Map<String, dynamic> toJson() => _$ReminderToJson(this);

  @override
  String toString() {
    return '{dt: $dt, notifId: $notifId}';
  }
}
