import 'dart:math';
import 'package:app/screens/home/flutter_diagram.dart';
import 'package:app/screens/home/notification.dart';
import 'package:app/screens/home/theme_manager.dart';
import 'package:app/screens/home/transactions/transactions_detailview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../firebase_options.dart';
import '../../services/auth_service.dart';
import 'menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Calendar());
  /* runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => new ThemeNotifier(),
    child: Calendar(),
  )); */
}

class Calendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Calendar';
    return MaterialApp(
      title: appTitle,
      theme: Theme.of(context),
      home: Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text(appTitle),
          backgroundColor: Colors.grey,
        ),
        body: MyCalendar(),
      ),
    );
  }
}

class MyCalendar extends StatefulWidget {
  @override
  Cal createState() {
    return Cal();
  }
}

class Cal extends State<MyCalendar> {
  late CalendarController _controller;
  List<Color> _colorCollection = <Color>[];
  MeetingDataSource? events;
  final databaseReference = FirebaseFirestore.instance;
  late List<Meeting> meetings;

  @override
  void initState() {
    _controller = CalendarController();
    getDataFromFireStore().then((results) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    });
    super.initState();
  }

  Future<void> getDataFromFireStore() async {
    final AuthService _authService = AuthService();
    User? user = _authService.getuser();

//incomes - different color
    var incomeSnapShots = await FirebaseFirestore.instance
        .collection("transactions")
        .where('uid', isEqualTo: user!.uid)
        .where('expense', isEqualTo: false)
        .get();
//expenses - different color
    var expenseSnapShots = await FirebaseFirestore.instance
        .collection("transactions")
        .where('uid', isEqualTo: user.uid)
        .where('expense', isEqualTo: true)
        .get();

    List<Meeting> incomes = incomeSnapShots.docs
        .map((e) => Meeting(
            e.data()['title'],
            (e.data()['date'] as Timestamp).toDate(),
            (e.data()['date'] as Timestamp).toDate(),
            Colors.green,
            true))
        .toList();

    List<Meeting> expenses = expenseSnapShots.docs
        .map((e) => Meeting(
            e.data()['title'],
            (e.data()['date'] as Timestamp).toDate(),
            (e.data()['date'] as Timestamp).toDate(),
            Colors.black,
            true))
        .toList();

    List<Meeting> bigList = incomes + expenses;

    setState(() {
      events = MeetingDataSource(bigList);
    });
  }

  getDataFromDatabase() async {
    final AuthService _authService = AuthService();
    User? user = _authService.getuser();
    var value = FirebaseFirestore.instance
        .collection('transactions')
        .where("uid", isEqualTo: user!.uid)
        .snapshots();
    return value;
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    Meeting meeting = calendarTapDetails.appointments![0];
    if (calendarTapDetails.targetElement == CalendarElement.appointment) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TransactionDetailview(meeting.eventName)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavDrawer(),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () => setState(() {
                if (_controller.view == CalendarView.day) {
                  _controller.view = CalendarView.month;
                } else {
                  _controller.view = CalendarView.day;
                }
                print(_controller.view);
              }),
              child: Text('Change the view'),
            ),
            SfCalendar(
              controller: _controller,
              view: CalendarView.month,
              //initialDisplayDate: DateTime(2023, 4, 5, 9, 0, 0),
              dataSource: events,
              monthViewSettings: MonthViewSettings(
                showAgenda: true,
              ),
              onTap: calendarTapped,
            ),
          ],
        ));
  }
}

class TransactionEvent {
  TransactionEvent(this.eventName, this.startTime, this.endTime, this.isAllDay,
      this.background);

  String eventName;
  DateTime startTime;
  DateTime endTime;
  bool isAllDay;
  Color background;
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}
