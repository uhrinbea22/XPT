import 'package:app/consts/styles.dart';
import 'package:app/screens/home/menu.dart';
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
    const screenTitle = 'Diagramok';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: screenTitle,
      theme: Theme.of(context),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: NavDrawer(),
        appBar: AppBar(
          title: const Text(screenTitle),
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
  bool allData = false;
  num allExpenseAmount = 0;
  num allIncomeAmount = 0;
  final String actualMonthStart =
      '${DateTime.now().year}-0${DateTime.now().month}-01';
  final String nextMonthStart =
      '${DateTime.now().year}-0${DateTime.now().month + 1}-01';

  @override
  void dispose() {
    didDispose = true;
    super.dispose();
  }

  Future loadChartData() async {
    var snapShotsValue = allData == false
        ? await FirebaseFirestore.instance
            .collection("transactions")
            .where('uid', isEqualTo: _authService.getuser()!.uid)
            .where('date', isGreaterThanOrEqualTo: actualMonthStart)
            .where('date', isLessThan: nextMonthStart)
            .get()
        : await FirebaseFirestore.instance
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

    /// find those categories which has more than one amount and sum those
    for (int i = 0; i < categories.length; i++) {
      if (categoriesOnce.contains(categories[i])) {
        TransactionDetails tr = listWithDuplicates
            .firstWhere((element) => element.category == categories[i]);
        tr.amount = (tr.amount! + amounts[i]) as int?;
      } else {
        listWithDuplicates.add(TransactionDetails(categories[i], amounts[i]));
        categoriesOnce.add(categories[i]);
      }
    }

    /// delete duplicates from list
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
    ///load all or only the proper month's the expenses and incomes
    allExpenseAmount = 0;
    allIncomeAmount = 0;
    var snapShotsValue = allData
        ? await FirebaseFirestore.instance
            .collection("transactions")
            .where('uid', isEqualTo: _authService.getuser()!.uid)
            .get()
        : await FirebaseFirestore.instance
            .collection("transactions")
            .where('uid', isEqualTo: _authService.getuser()!.uid)
            .where('date', isGreaterThanOrEqualTo: actualMonthStart)
            .where('date', isLessThan: nextMonthStart)
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
          TransactionDetails("Kiadás", allExpenseAmount as int, Colors.black),
          TransactionDetails("Bevétel", allIncomeAmount as int, Colors.green)
        ];
      });
    }
  }

  Future loadLimitData() async {
    ///sum amounts of categories and compare to category limit
    var snapShotsValue = allData
        ? await FirebaseFirestore.instance
            .collection("transactions")
            .where('uid', isEqualTo: _authService.getuser()!.uid)
            .get()
        : await FirebaseFirestore.instance
            .collection("transactions")
            .where('uid', isEqualTo: _authService.getuser()!.uid)
            .where('date', isGreaterThanOrEqualTo: actualMonthStart)
            .where('date', isLessThan: nextMonthStart)
            .get();

    List categories =
        snapShotsValue.docs.map((e) => (e.data()['category'])).toList();

    List amounts =
        snapShotsValue.docs.map((e) => (e.data()['amount'])).toList();

    List<String> categoriesOnce = [];
    List<TransactionDetails> listWithDuplicates = [];
    List<TransactionDetails> list = [];

    /// find those categories which has more than one amount
    /// than add those amounts
    for (int i = 0; i < categories.length; i++) {
      if (categoriesOnce.contains(categories[i])) {
        TransactionDetails tr = listWithDuplicates
            .firstWhere((element) => element.category == categories[i]);
        tr.amount = (tr.amount! + amounts[i]) as int?;
      } else {
        listWithDuplicates.add(TransactionDetails(categories[i], amounts[i]));
        categoriesOnce.add(categories[i]);
      }
    }

    /// delete duplicates from list
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

    ///list has the category name and the actual amount, we have to add the limit to that
    var limitSnapshots = allData
        ? await FirebaseFirestore.instance
            .collection("category_limits")
            .where('uid', isEqualTo: _authService.getuser()!.uid)
            .get()
        : await FirebaseFirestore.instance
            .collection("category_limits")
            .where('uid', isEqualTo: _authService.getuser()!.uid)
            .where('date', isGreaterThanOrEqualTo: actualMonthStart)
            .where('date', isLessThan: nextMonthStart)
            .get();

    List limitCategories =
        limitSnapshots.docs.map((e) => (e.data()['category'])).toList();

    List limitValues =
        limitSnapshots.docs.map((e) => (e.data()['limit'])).toList();

    List<TransactionDetails> lista = [];

    for (int i = 0; i < list.length; i++) {
      if (limitCategories.contains(list[i].category)) {
        var index = limitCategories.indexOf(list[i].category);
        var tr = TransactionDetails.limit(
          list[i].category.toString(),
          int.parse(limitValues[index]),
          list[i].amount,
        );
        lista.add(tr);
      }
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
    allData = false;
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
            padding: EdgeInsets.all(5.0),
            alignment: Alignment.center,
            child: Text(
              "Aktuális egyenleg : ${allIncomeAmount - allExpenseAmount} $valuta",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
              /*  */
              alignment: Alignment.center,
              child: ElevatedButton(
                child:
                    Text(allData ? "Havi kimutatás" : "Összesített kimutatás"),
                onPressed: () async {
                  setState(() {
                    allData = !allData;
                    loadChartData();
                    loadExpenseData();
                    loadLimitData();
                  });
                },
              )),
          Container(
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: SfCartesianChart(
              title: ChartTitle(text: "Tranzakciók vizsgálata kategóriánként"),
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
              title: ChartTitle(text: "Tranzakciók vizsgálata kategóriánként"),
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
                title: ChartTitle(text: "Bevételek és kiadások aránya"),
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
              title: ChartTitle(
                  text:
                      "Kategóriákra beállított limitek, és eddig elköltött összeg"),
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(),
              enableSideBySideSeriesPlacement: false,
              legend: Legend(
                isVisible: true,
                legendItemBuilder:
                    (String name, dynamic series, dynamic point, int index) {
                  return SizedBox(
                    height: 30.0,
                    width: 60.0,
                    child: SizedBox(child: Text(series.name)),
                  );
                },
              ),
              series: <ChartSeries>[
                ColumnSeries<TransactionDetails, String>(
                    width: 0.35,
                    dataSource: limitData,
                    dataLabelMapper: (TransactionDetails details, _) =>
                        "Kategória Limit",
                    xValueMapper: (TransactionDetails details, _) =>
                        details.category,
                    yValueMapper: (TransactionDetails details, _) =>
                        details.categoryLimit,
                    color: Colors.pink,
                    name: "Limit"),
                ColumnSeries<TransactionDetails, String>(
                    dataSource: limitData,
                    width: 0.25,
                    dataLabelMapper: (TransactionDetails details, _) =>
                        details.categoryLimit.toString(),
                    xValueMapper: (TransactionDetails details, _) =>
                        details.category,
                    yValueMapper: (TransactionDetails details, _) =>
                        details.amount,
                    color: Colors.lightBlue,
                    name: "Elköltött"),
              ],
            ),
          ),
        ],
      )),
    );
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
