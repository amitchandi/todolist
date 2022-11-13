import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'reminder.dart';
import 'item.dart';
import 'dart:convert';

class MainModel extends ChangeNotifier {
  final List<Item> _list = [];

  MainModel() {
    _getList().then((value) {
      notifyListeners();
    });
  }

  List<Item> get list => _list;

  saveDetail(detail, index) {
    _list[index].detail = detail;
    save(true);
  }

  saveDueDate(DateTime dueDate, int index, int notifId) {
    _list[index].dueDate = dueDate.toString();
    _list[index].dueDateNotifId = notifId;
    save(true);
  }

  delDueDate(index) {
    _list[index].dueDate = '';
    _list[index].reminders = [];
    save(true);
  }

  addReminder(DateTime dt, int index, int notifId) {
    _list[index].reminders;
    _list[index].reminders.add(Reminder(dt: dt.toString(), notifId: notifId));
    save(true);
  }

  delReminder(int listIndex, reminder) {
    _list[listIndex].reminders.remove(reminder);
    save(true);
  }

  save(bool isNotify) {
    _convert().then((value) {
      if (isNotify) {
        notifyListeners();
      }
    });
  }

  addItm({title, isChecked}) {
    _list.add(Item(
        id: const Uuid().v4().toString(),
        title: title,
        detail: '',
        isChecked: isChecked,
        dueDate: '',
        dueDateNotifId: -1,
        reminders: []));
    save(true);
  }

  delItm(item) {
    _list.remove(item);
    save(true);
  }

  Future<void> _getList() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('list')) {
      await (_convert());
    }
    var list = jsonDecode(prefs.getString('list') ?? '')['items'];
    list.forEach((element) {
      debugPrint(Item.fromJson(element).toString());
      _list.add(Item.fromJson(element));
    });
  }

  Future<void> _convert() async {
    final prefs = await SharedPreferences.getInstance();
    var json = jsonEncode({'items': _list});
    prefs.setString('list', json);
  }
}
