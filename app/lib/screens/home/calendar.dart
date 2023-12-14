import 'package:app/screens/home/transactions/transactions_detailview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
}

class Calendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const appTitle = 'Naptár';
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: NavDrawer(),
        appBar: AppBar(
          title: const Text(appTitle),
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
  TransactionDataSource? events;
  final databaseReference = FirebaseFirestore.instance;
  late List<TransactionEvent> meetings;

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

    ///incomes - different color
    var incomeSnapShots = await FirebaseFirestore.instance
        .collection("transactions")
        .where('uid', isEqualTo: user!.uid)
        .where('expense', isEqualTo: false)
        .get();

    ///expenses - different color
    var expenseSnapShots = await FirebaseFirestore.instance
        .collection("transactions")
        .where('uid', isEqualTo: user.uid)
        .where('expense', isEqualTo: true)
        .get();

    List<TransactionEvent> incomes = incomeSnapShots.docs
        .map((e) => TransactionEvent(
              e.data()['title'],
              DateTime.parse(e.data()['date']),
              DateTime.parse(e.data()['date']),
              true,
              Colors.green,
            ))
        .toList();

    List<TransactionEvent> expenses = expenseSnapShots.docs
        .map((e) => TransactionEvent(
              e.data()['title'],
              DateTime.parse(e.data()['date']),
              DateTime.parse(e.data()['date']),
              true,
              Colors.black,
            ))
        .toList();

    List<TransactionEvent> bigList = incomes + expenses;

    setState(() {
      events = TransactionDataSource(bigList);
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
    TransactionEvent meeting = calendarTapDetails.appointments![0];
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
        body: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 25),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  onPressed: () => setState(() {
                    _controller.view = CalendarView.month;
                  }),
                  child: const Text('Havi nézet'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _controller.view = CalendarView.week;
                  }),
                  child: const Text('Heti nézet'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _controller.view = CalendarView.day;
                  }),
                  child: const Text('Napi nézet'),
                ),
              ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      _controller.backward!();
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      _controller.forward!();
                    },
                  ),
                )
              ],
            ),
            SfCalendar(
              controller: _controller,
              view: CalendarView.month,
              dataSource: events,
              monthViewSettings: const MonthViewSettings(
                showAgenda: true,
              ),
              onTap: calendarTapped,
            ),
          ],
        )));
  }
}

class TransactionEvent {
  TransactionEvent(
      this.eventName, this.from, this.to, this.isAllDay, this.background);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}

///model for displaying data in calendar
class TransactionDataSource extends CalendarDataSource {
  TransactionDataSource(List<TransactionEvent> source) {
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
