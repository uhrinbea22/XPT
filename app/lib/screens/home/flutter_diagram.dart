import 'package:app/screens/home/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
        .map((e) => TransactionDetails.expense(
            e.data()['amount'], e.data()['expense'] ? 'Expense' : "Income"))
        .toList();
    for (int i = 0; i < list.length; i++) {
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

  Future loadLimitData() async {
    //add amounts of categories and show them through the limit
    num allExpenseAmount = 0;
    num allIncomeAmount = 0;
    num limit = 0;
    List limitCategories = [];
    Map limitMap = {};
    Map amountMap = {};

    var categoryLimitSnapshot = await FirebaseFirestore.instance
        .collection("category_limits")
        .where('uid', isEqualTo: _authService.getuser()!.uid)
        .get();

    List categoryNameList = categoryLimitSnapshot.docs.toList();

    var snapShotsValue = await FirebaseFirestore.instance
        .collection("transactions")
        .where('uid', isEqualTo: _authService.getuser()!.uid)
        .get();
    List list = snapShotsValue.docs.toList();

    for (int i = 0; i < list.length; i++) {
      for (int j = 0; j < categoryNameList.length; j++) {
        if (list[i]['category'] == categoryNameList[j]['category']) {
          limit += list[i]['amount'];
          limitCategories.add(list[i]['category']);
          limitMap.addAll({list[i]['category']: categoryNameList[j]['limit']});
          amountMap.addAll({list[i]['category']: limit});
        }
      }
    }
    //limitMap has the data we want to visualize

    List<TransactionDetails> categoryLimitList = snapShotsValue.docs
        .map((e) => TransactionDetails.expense(e.data()['amount'],
            e.data()['expense'] ? 'Expense' : "Income", e.data()['color']))
        .toList();

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
    loadLimitData();

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
                    primaryYAxis: NumericAxis(
                        minimum: 0, maximum: 150000, interval: 1000),
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
                //TODO : colors are not good 
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
