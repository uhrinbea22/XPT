import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
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
    final appTitle = 'Flutter Form Demo';
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
  late CalendarView view2 = CalendarView.month;
  late List<Meeting> meetings;
  var _streamTransactions;
  @override
  Cal createState() {
    return Cal();
  }
}

class Cal extends State<MyCalendar> {
  late CalendarView view2 = CalendarView.month;
  List<Meeting> meetings = [];
  @override
  void initState() {
    getData();
    view2 = view2;
    super.initState();
  }

  void changeView(val) {
    setState(() {
      view2 = val;
    });
    build(context) {
      return SfCalendar(view: CalendarView.day);
    }
  }

  @override
  void didUpdateWidget(covariant MyCalendar oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: SfCalendar(
                view: view2,
                dataSource: MeetingDataSource(_getDataSource()),
                monthViewSettings: MonthViewSettings(
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.appointment),
                todayHighlightColor: Colors.red,
                onTap: (calendarTapDetails) {
                  print(calendarTapDetails);
                  print(view2);
                  changeView(CalendarView.day);
                  print(view2);
                  didUpdateWidget(MyCalendar());
                })));
  }

  getDailyView() {
    return Scaffold(
        body: Container(
            child: SfCalendar(
      view: CalendarView.day,
      dataSource: MeetingDataSource(_getDataSource()),
    )));
  }

  getData() async {
    final AuthService _authService = AuthService();
    User? user = _authService.getuser();
    Map<Timestamp, List<String>> map = {};
    await for (var messages in FirebaseFirestore.instance
        .collection('transactions')
        .where('uid', isEqualTo: user?.uid)
        .snapshots()) {
      for (var date in messages.docs.toList()) {
        Meeting meeting =
            new Meeting(date['title'], date['date'], const Color(0xFF0F8644));
        print(meeting.time);
        meetings.add(meeting);
      }
    }
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = this.meetings;
    return meetings;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  Timestamp getTime(int index) {
    return appointments![index].time;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }
}

class Meeting {
  Meeting(this.eventName, this.time, this.background);

  String eventName;
  Timestamp time;
  Color background;
}
