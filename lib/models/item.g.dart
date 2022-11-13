// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
      id: json['id'] as String,
      title: json['title'] as String,
      detail: json['detail'] as String,
      isChecked: json['isChecked'] as bool,
      dueDate: json['dueDate'] as String,
      dueDateNotifId: json['dueDateNotifId'] as int,
      reminders: (json['reminders'] as List<dynamic>)
          .map((e) => Reminder.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'detail': instance.detail,
      'isChecked': instance.isChecked,
      'dueDate': instance.dueDate,
      'dueDateNotifId': instance.dueDateNotifId,
      'reminders': instance.reminders,
    };
