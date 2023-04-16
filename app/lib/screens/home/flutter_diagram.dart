import 'package:app/screens/home/menu.dart';
import 'package:app/screens/home/theme_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class DiagramScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Diagrams';
    return MaterialApp(
      title: appTitle,
      theme: Theme.of(context),
      home: Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: RealtimeDiagram(),
      ),
    );
  }
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
  List<TransactionDetails> limitData = [];
  var maxTransactionAmount = 0;

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

    List categories =
        snapShotsValue.docs.map((e) => (e.data()['category'])).toList();

    List amounts =
        snapShotsValue.docs.map((e) => (e.data()['amount'])).toList();

    List<String> categoriesOnce = [];
    List<TransactionDetails> listWithDuplicates = [];
    List<TransactionDetails> list = [];

// find those categories which has more than one amount
// than add those amounts
    for (int i = 0; i < categories.length; i++) {
      if (categoriesOnce.contains(categories[i])) {
        TransactionDetails tr = listWithDuplicates
            .firstWhere((element) => element.category == categories[i]);
        tr.amount = (tr.amount! + amounts[i]) as int?;
        listWithDuplicates.add(tr);
      } else {
        listWithDuplicates.add(TransactionDetails(categories[i], amounts[i]));
        categoriesOnce.add(categories[i]);
      }
    }

// delete duplicates from list
    for (int i = 0; i < listWithDuplicates.length; i++) {
      if (list.contains(listWithDuplicates[i])) {
      } else {
        list.add(listWithDuplicates[i]);
      }
    }

    for (int i = 0; i < list.length; i++) {
      if (list[i].amount! > maxTransactionAmount) {
        maxTransactionAmount = list[i].amount!;
      }
    }

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
          TransactionDetails("Expense", allExpenseAmount as int, Colors.black),
          TransactionDetails("Income", allIncomeAmount as int, Colors.green)
        ];
      });
    }
  }

  Future loadLimitData() async {
    //add amounts of categories and show them through the limit
    var snapShotsValue = await FirebaseFirestore.instance
        .collection("transactions")
        .where('uid', isEqualTo: _authService.getuser()!.uid)
        .get();

    List categories =
        snapShotsValue.docs.map((e) => (e.data()['category'])).toList();

    List amounts =
        snapShotsValue.docs.map((e) => (e.data()['amount'])).toList();

    List<String> categoriesOnce = [];
    List<TransactionDetails> listWithDuplicates = [];
    List<TransactionDetails> list = [];

// find those categories which has more than one amount
// than add those amounts
    for (int i = 0; i < categories.length; i++) {
      if (categoriesOnce.contains(categories[i])) {
        TransactionDetails tr = listWithDuplicates
            .firstWhere((element) => element.category == categories[i]);
        tr.amount = (tr.amount! + amounts[i]) as int?;
        listWithDuplicates.add(tr);
      } else {
        listWithDuplicates.add(TransactionDetails(categories[i], amounts[i]));
        categoriesOnce.add(categories[i]);
      }
    }

// delete duplicates from list
    for (int i = 0; i < listWithDuplicates.length; i++) {
      if (list.contains(listWithDuplicates[i])) {
      } else {
        list.add(listWithDuplicates[i]);
      }
    }

    for (int i = 0; i < list.length; i++) {
      if (list[i].amount! > maxTransactionAmount) {
        maxTransactionAmount = list[i].amount!;
      }
    }

    //list has the category name and the actual amount, we have to add the limit to that

    var limitSnapshots = await FirebaseFirestore.instance
        .collection("category_limits")
        .where('uid', isEqualTo: _authService.getuser()!.uid)
        .get();

    List limitCategories =
        limitSnapshots.docs.map((e) => (e.data()['category'])).toList();

    List limitValues =
        limitSnapshots.docs.map((e) => (e.data()['limit'])).toList();

    for (int i = 0; i < limitValues.length; i++) {
      print(limitValues[i]);
    }
    List<TransactionDetails> lista = [];

    for (int i = 0; i < list.length; i++) {
      for (int j = 0; j < limitCategories.length; j++) {
        if (list[i].category == limitCategories[j]) {
          var tr = TransactionDetails.limit(
            list[i].category,
            int.parse(limitValues[j]),
            list[i].amount,
          );
          lista.add(tr);
          print(limitValues[j]);
        }
      }
    }

    for (int i = 0; i < lista.length; i++) {
      print("Category");
      print(lista[i].category);
      print('amount');
      print(lista[i].amount);
      print('limit');
      print(lista[i].categoryLimit);
      print(lista[i].categoryLimit.runtimeType);
    }

    setState(() {
      limitData = lista;
    });
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
    return Scaffold(
        drawer: NavDrawer(),
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: SfCartesianChart(
                title: ChartTitle(text: "Transactions group by categories"),
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(
                    minimum: 0.0,
                    maximum: double.parse(maxTransactionAmount.toString()),
                    interval: 1000.0),
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
                title: ChartTitle(text: "Transactions group by categories"),
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
                  title: ChartTitle(text: "Expense and income ratio"),
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
                )),
            Container(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: SfCartesianChart(
                title: ChartTitle(text: "Transactions group by categories"),
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(),
                enableSideBySideSeriesPlacement: false,
                legend: Legend(
                  isVisible: true,
                  legendItemBuilder:
                      (String name, dynamic series, dynamic point, int index) {
                    return SizedBox(
                        height: 20.0,
                        width: 50.0,
                        child: Row(children: <Widget>[
                          SizedBox(child: Text(series.name)),
                        ]));
                  },
                ),
                series: <ChartSeries>[
                  ColumnSeries<TransactionDetails, String>(
                      width: 0.4,
                      dataSource: limitData,
                      dataLabelMapper: (TransactionDetails details, _) =>
                          "Category Limit",
                      xValueMapper: (TransactionDetails details, _) =>
                          details.category,
                      yValueMapper: (TransactionDetails details, _) =>
                          details.categoryLimit,
                      color: Colors.pink,
                      name: "Limit"),
                  ColumnSeries<TransactionDetails, String>(
                      dataSource: limitData,
                      width: 0.2,
                      dataLabelMapper: (TransactionDetails details, _) =>
                          details.categoryLimit.toString(),
                      xValueMapper: (TransactionDetails details, _) =>
                          details.category,
                      yValueMapper: (TransactionDetails details, _) =>
                          details.amount,
                      color: Colors.lightBlue,
                      name: "Spent"),
                ],
              ),
            ),
          ],
        )));
  }
}

class TransactionDetails {
  TransactionDetails(this.category, this.amount, [this.color]);
  TransactionDetails.expense(this.amount, this.expense, [this.color]);
  TransactionDetails.limit(this.category, this.categoryLimit, this.amount);
  String? category;
  int? amount;
  String? expense;
  Color? color;
  int? categoryLimit;

  factory TransactionDetails.fromJson(Map<String, dynamic> parsedJson) {
    return TransactionDetails(
        parsedJson['category'].toString(), parsedJson['amount']);
  }
}
