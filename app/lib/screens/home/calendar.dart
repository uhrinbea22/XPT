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
  late CalendarView view2 = CalendarView.month;
  late List<TransactionEvent> meetings;
  var _streamTransactions;
  @override
  Cal createState() {
    return Cal();
  }
}

class Cal extends State<MyCalendar> {
  late CalendarView view2 = CalendarView.month;
  List<TransactionEvent> meetings = [];
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
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: SfCalendar(
                view: view2,
                dataSource: MeetingDataSource(_getDataSource()),
                monthViewSettings: const MonthViewSettings(
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.appointment),
                todayHighlightColor: Colors.red,
                onTap: (calendarTapDetails) {})));
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
        TransactionEvent meeting = TransactionEvent(
            date['title'], date['date'], const Color(0xFF0F8644));
        print(meeting.time);
        meetings.add(meeting);
      }
    }
    return meetings;
  }

  List<TransactionEvent> _getDataSource() {
    final List<TransactionEvent> meetings = this.meetings;
    return meetings;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<TransactionEvent> source) {
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

class TransactionEvent {
  TransactionEvent(this.eventName, this.time, this.background);

  String eventName;
  Timestamp time;
  Color background;
}
