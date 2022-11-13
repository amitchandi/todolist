// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/item.dart';
import 'models/main_model.dart';
import 'notification_service.dart';

void main() {
  return runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'To Do List',
      home: MyHomePage(
        title: 'To Do List',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final NotificationService notificationService;
  final _indieFlower = GoogleFonts.indieFlower(fontWeight: FontWeight.w900);
  @override
  void initState() {
    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();
    super.initState();
  }

  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        debugPrint(payload);
      });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MainModel>(
      create: (context) => MainModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: _indieFlower,
          ),
          backgroundColor: const Color.fromARGB(255, 129, 104, 68),
        ),
        backgroundColor: const Color.fromARGB(248, 255, 228, 132),
        body: Center(
            child: MyList(
          notificationService: notificationService,
        )),
        floatingActionButton: Consumer<MainModel>(
          builder: (context, model, child) {
            return FloatingActionButton(
              onPressed: () {
                model.addItm(title: 'new item', isChecked: false);
              },
              tooltip: 'Add Item',
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}

class MyList extends StatefulWidget {
  const MyList({
    super.key,
    required this.notificationService,
  });

  final NotificationService notificationService;

  @override
  State<MyList> createState() => _MyListState();
}

class _MyListState extends State<MyList> {
  final _indieFlower = GoogleFonts.indieFlower(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Consumer<MainModel>(builder: (context, model, child) {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: model.list.length,
        itemBuilder: (context, index) {
          Item item = model.list[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                child: ListTile(
                  title: TextField(
                    decoration: const InputDecoration.collapsed(hintText: ''),
                    controller: TextEditingController()..text = item.title,
                    onChanged: (value) {
                      item.title = value;
                      model.save(false);
                    },
                    onSubmitted: (value) {
                      model.save(false);
                    },
                    style: _indieFlower,
                  ),
                  leading: Checkbox(
                    value: item.isChecked,
                    onChanged: (value) {
                      setState(() {
                        item.isChecked = value!;
                        model.save(false);
                      });
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        splashRadius: 0.1,
                        onPressed: () {
                          setState(() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                    item: item,
                                    index: index,
                                    model: model,
                                    notificationService:
                                        widget.notificationService,
                                  ),
                                ));
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_rounded),
                        splashRadius: 0.1,
                        onPressed: () {
                          setState(() {
                            model.delItm(item);
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
              const Divider(
                color: Colors.black,
              )
            ],
          );
        },
      );
    });
  }
}

class DetailScreen extends StatefulWidget {
  const DetailScreen(
      {super.key,
      required this.item,
      required this.index,
      required this.model,
      required this.notificationService});

  final Item item;
  final int index;
  final MainModel model;
  final NotificationService notificationService;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Select for Date
  Future<DateTime?> _selectDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
  }

  // Select for Time
  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  List<Widget> _createReminders() {
    var list = <Widget>[];
    for (var reminder in widget.item.reminders) {
      debugPrint(reminder.dt);
      list.add(Row(children: [
        Text(reminder.dt.toString().replaceAll(':00.000', '')),
        IconButton(
          onPressed: () {
            setState(() {
              widget.model.delReminder(widget.index, reminder);
            });
            widget.notificationService.cancelNotification(reminder.notifId);
          },
          icon: const Icon(
            Icons.delete_forever_rounded,
            color: Colors.blue,
          ),
        )
      ]));
    }
    return list;
  }

  _dateTimeSelect(Function(DateTime) fn) {
    var date;
    var time;
    _selectDate(context).then((value) {
      date = value;
    }).whenComplete(() {
      if (date == null) {
        return;
      }
      _selectTime(context).then((value) {
        time = value;
      }).whenComplete(() {
        if (date != null && time != null) {
          var dt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          if (dt.isAfter(DateTime.now())) {
            fn(dt);
          } else {
            const snackBar = SnackBar(
              content: Text(
                  'Please select a date and time after the current date and time.'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(
            decoration: const InputDecoration.collapsed(hintText: 'Details'),
            controller: TextEditingController()..text = widget.item.detail,
            maxLines: null,
            onChanged: (value) {
              widget.model.saveDetail(value, widget.index);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  _dateTimeSelect((DateTime dt) {
                    widget.notificationService
                        .scheduleNotification(dt, widget.item.title, 'Due Now')
                        .then((notifId) {
                      setState(() {
                        widget.model.saveDueDate(dt, widget.index, notifId);
                      });
                    });
                  });
                },
                child: const Icon(Icons.calendar_month_outlined),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(widget.item.dueDate == ''
                    ? 'Due Date Not Set'
                    : widget.item.dueDate.replaceFirst(':00.000', '')),
              ),
              IconButton(
                color: widget.item.dueDate == ''
                    ? Colors.transparent
                    : Colors.blue,
                onPressed: () {
                  setState(() {
                    widget.model.delDueDate(widget.index);
                  });
                  widget.notificationService
                      .cancelNotification(widget.item.dueDateNotifId);
                },
                icon: const Icon(Icons.backspace_rounded),
                splashRadius: 0.1,
              ),
            ],
          ),
          widget.item.dueDate == '' ||
                  DateTime.parse(widget.item.dueDate).isBefore(DateTime.now())
              ? const Text('')
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                      Column(children: [
                        const Text('Reminders: '),
                        IconButton(
                            splashRadius: 15,
                            onPressed: () {
                              _dateTimeSelect((dt) {
                                widget.notificationService
                                    .scheduleNotification(dt, widget.item.title,
                                        'Due: ${widget.item.dueDate.replaceFirst(':00.000', '')}')
                                    .then((notifId) {
                                  setState(() {
                                    widget.model
                                        .addReminder(dt, widget.index, notifId);
                                  });
                                });
                              });
                            },
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.blue,
                            ))
                      ]),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: _createReminders(),
                      ),
                    ])
        ]),
      ),
    );
  }
}
