import 'package:app/screens/home/menu.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DiagramPage extends StatelessWidget {
  DiagramPage({Key? key}) : super(key: key);
  final List<TransactData> _chartData = [
    TransactData('Pet', 2000),
    TransactData('Food', 20000),
    TransactData('Clothes', 10000),
    TransactData('SPA', 1000),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          drawer: NavDrawer(),
      body: SfCircularChart(
        series: <CircularSeries>[
          PieSeries<TransactData, String>(
            dataSource: _chartData,
            xValueMapper: (TransactData data, _) => data.categ,
            yValueMapper: (TransactData data, _) => data.amount,
            // dataLabelSettings: DataLabelSettings(isVisible: true)
          )
        ],
      ),
    ));
  }

  List<TransactData> getChartData() {
    final List<TransactData> chartData = [
      TransactData('Pet', 2000),
      TransactData('Food', 20000),
      TransactData('Clothes', 10000),
      TransactData('SPA', 1000),
    ];
    return chartData;
  }
}

class TransactData {
  TransactData(this.categ, this.amount);
  final String categ;
  final int amount;
}
