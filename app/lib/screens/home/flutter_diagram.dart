import 'dart:convert';

import 'package:app/screens/home/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart';

import '../../firebase_options.dart';
import '../../services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(RealtimeDiagram());
}

class RealtimeDiagram extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<RealtimeDiagram> {
  bool didDispose = false;
  final AuthService _authService = AuthService();
  List<TransactionDetails> chartData = [];
  List<TransactionDetails> expenseData = [];

  @override
  void dispose() {
    didDispose = true;
    super.dispose();
  }

  Future loadChartData() async {
    var snapShotsValue = await FirebaseFirestore.instance
        .collection("transactions")
        .where('uid', isEqualTo: _authService.getuser()!.uid)
        .get();
    List<TransactionDetails> list = snapShotsValue.docs
        .map(
            (e) => TransactionDetails(e.data()['category'], e.data()['amount']))
        .toList();
    if (!mounted) return;
    setState(() {
      chartData = list;
    });
  }

  Future loadExpenseData() async {
    num allExpenseAmount = 0;
    num allIncomeAmount = 0;
    var snapShotsValue = await FirebaseFirestore.instance
        .collection("transactions")
        .where('uid', isEqualTo: _authService.getuser()!.uid)
        .get();
    List<TransactionDetails> list = snapShotsValue.docs
        .map((e) => TransactionDetails.expense(e.data()['amount'],
            e.data()['expense'] ? 'Expense' : "Income", e.data()['color']))
        .toList();
    for (int i = 0; i < list.length; i++) {
      print(list[i].amount);
      if (list[i].expense == "Expense") {
        allExpenseAmount += list[i].amount!;
      } else {
        allIncomeAmount += list[i].amount!;
      }
    }

    if (!mounted) return;
    if (mounted) {
      setState(() {
        expenseData = [
          TransactionDetails("Expense", allExpenseAmount as int),
          TransactionDetails("Income", allIncomeAmount as int)
        ];
      });
    }
  }

  @override
  void initState() {
    loadChartData();
    loadExpenseData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            drawer: NavDrawer(),
            body: SingleChildScrollView(
                child: Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: SfCartesianChart(
                    title: ChartTitle(text: "ELSO"),
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis:
                        NumericAxis(minimum: 0, maximum: 15000, interval: 1000),
                    series: <ChartSeries>[
                      ColumnSeries<TransactionDetails, String>(
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            color: Colors.purple,
                          ),
                          dataSource: chartData,
                          dataLabelMapper: (TransactionDetails details, _) =>
                              details.category,
                          xValueMapper: (TransactionDetails details, _) =>
                              details.category,
                          yValueMapper: (TransactionDetails details, _) =>
                              details.amount),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: SfCircularChart(
                    title: ChartTitle(text: "masodik"),
                    series: <PieSeries>[
                      PieSeries<TransactionDetails, String>(
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            color: Colors.purple,
                          ),
                          dataSource: chartData,
                          dataLabelMapper: (TransactionDetails details, _) =>
                              details.category,
                          xValueMapper: (TransactionDetails details, _) =>
                              details.category,
                          yValueMapper: (TransactionDetails details, _) =>
                              details.amount),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: SfCircularChart(
                    title: ChartTitle(text: "harmadik"),
                    series: <PieSeries>[
                      PieSeries<TransactionDetails, String>(
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            color: Colors.purple,
                          ),
                          dataLabelMapper: (TransactionDetails details, _) =>
                              details.category,
                          dataSource: expenseData,
                          xValueMapper: (TransactionDetails details, _) =>
                              details.expense.toString(),
                          yValueMapper: (TransactionDetails details, _) =>
                              details.amount),
                    ],
                  ),
                ),
              ],
            ))));
  }
}

class TransactionDetails {
  TransactionDetails(this.category, this.amount, [this.color]);
  TransactionDetails.expense(this.amount, this.expense, [this.color]);
  String? category;
  int? amount;
  String? expense;
  Color? color;

  factory TransactionDetails.fromJson(Map<String, dynamic> parsedJson) {
    return TransactionDetails(
        parsedJson['category'].toString(), parsedJson['amount']);
  }
}
