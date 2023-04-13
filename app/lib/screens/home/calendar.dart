import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../firebase_options.dart';
import '../../services/auth_service.dart';
import 'menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyCalendar());
}

class Calendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Calendar';
    return MaterialApp(
      title: appTitle,
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

// Create a Form widget.
class MyCalendar extends StatefulWidget {
  @override
  Cal createState() {
    return Cal();
  }
}

class Cal extends State<MyCalendar> {
  List<Color> _colorCollection = <Color>[];
  MeetingDataSource? events;
  final databaseReference = FirebaseFirestore.instance;

  late CalendarView view2 = CalendarView.month;
  late List<Meeting> meetings;

  @override
  void initState() {
    //_initializeEventColor();
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

    var snapShotsValue = await FirebaseFirestore.instance
        .collection("transactions")
        .where('uid', isEqualTo: user!.uid)
        .get();

    final Random random = new Random();

    List<Meeting> list = snapShotsValue.docs
        .map((e) => Meeting(
            e.data()['title'],
            //DateFormat('dd/MM/yyyy HH:mm:ss').parse(e.data()['date']),
            //DateFormat('dd/MM/yyyy HH:mm:ss').parse(e.data()['date']),

            (e.data()['date'] as Timestamp).toDate(),
            (e.data()['date'] as Timestamp).toDate(),
            Colors.black,
            true))
        .toList();

    setState(() {
      events = MeetingDataSource(list);
    });
    for (var i = 0; i < events!.appointments!.length; i++) {
      print(events!.appointments![i].eventName);
      print(events!.appointments![i].from);
    }
  }

  getDataFromDatabase() async {
    final AuthService _authService = AuthService();
    User? user = _authService.getuser();
    var value = FirebaseFirestore.instance
        .collection('transactions')
        .where("uid", isEqualTo: user!.uid)
        .snapshots();
//    var getValue = await value.child('CalendarAppointmentCollection').once();
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SfCalendar(
      view: CalendarView.month,
      //initialDisplayDate: DateTime(2023, 4, 5, 9, 0, 0),
      dataSource: events,
      monthViewSettings: MonthViewSettings(
        showAgenda: true,
      ),
    ));
  }

  /*  _showCalendar() {
    var querySnapshot;
    var data;
    var collection;

    if (getDataFromDatabase() != null) {
      List<TransactionEvent> collection = [];
      var showData = querySnapshot.value;
      Map<dynamic, dynamic> values = showData;
      List<dynamic> key = values.keys.toList();
      if (values != null) {
        for (int i = 0; i < key.length; i++) {
          data = values[key[i]];
          final Random random = new Random();
          collection.add(TransactionEvent(
            eventName = data['title'],
            time: data['date'],
            background: _colorCollection[random.nextInt(9)],
          ));
        }
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }

      return SfCalendar(
        view: CalendarView.timelineDay,
        allowedViews: [
          CalendarView.timelineDay,
          CalendarView.timelineWeek,
          CalendarView.timelineWorkWeek,
          CalendarView.timelineMonth,
        ],
        initialDisplayDate: DateTime(2020, 4, 5, 9, 0, 0),
        dataSource: _getCalendarDataSource(collection),
        monthViewSettings: MonthViewSettings(showAgenda: true),
      );
    } */

  void _initializeEventColor() {
    this._colorCollection = [];
    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF8B1FA9));
    _colorCollection.add(const Color(0xFFD20100));
    _colorCollection.add(const Color(0xFFFC571D));
    _colorCollection.add(const Color(0xFF36B37B));
    _colorCollection.add(const Color(0xFF01A1EF));
    _colorCollection.add(const Color(0xFF3D4FB5));
    _colorCollection.add(const Color(0xFFE47C73));
    _colorCollection.add(const Color(0xFF636363));
    _colorCollection.add(const Color(0xFF0A8043));
  }

  /*  getData() async {
      final List<TransactionEvent> meetings = [];
      final AuthService _authService = AuthService();
      User? user = _authService.getuser();
      Map<Timestamp, List<String>> map = {};
      await for (var messages in FirebaseFirestore.instance
          .collection('transactions')
          .where('uid', isEqualTo: user?.uid)
          .snapshots()) {
        for (var date in messages.docs.toList()) {
          TransactionEvent meeting = TransactionEvent(
              date['title'], date['date'], const Color(0xFF0F8644));
          meetings.add(meeting);
        }
      }
      for (var i = 0; i < meetings.length; i++) {
        print(meetings[i].eventName);
        print(meetings[i].time);
        print(meetings[i].background);
      }
      print(meetings.length);
      return meetings;
    } */

  /*  List<TransactionEvent> _getDataSource() {
      final List<TransactionEvent> meetings = getData();
      return meetings;
    } */
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
