import 'package:app/screens/home/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../services/auth_service.dart';

class DiagramPage extends StatelessWidget {
  final AuthService _authService = AuthService();
  DiagramPage({Key? key}) : super(key: key);
  List<_ChartData> chartData = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      drawer: NavDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children :  <Widget> [
 SfCircularChart(
        series: <CircularSeries>[
          PieSeries<_ChartData, String>(
              dataSource: chartData,
              xValueMapper: (_ChartData data, _) => data.x,
              yValueMapper: (_ChartData data, _) => data.y)
        ],
      ),
        ]
      )
     
    ));
  }

  Future<void> getDataFromFireStore() async {
    var snapShotsValue =
        await FirebaseFirestore.instance.collection("transactions").get();
    print(snapShotsValue.size);
    List<_ChartData> list = snapShotsValue.docs
        .map((e) => _ChartData(x: e.data()['category'], y: e.data()['amount']))
        .toList();

    chartData = list;
    //setState(() {

    //chartData = list;

    // }
    //);
  }
}

class TransactData {
  TransactData(this.categ, this.amount);
  final String categ;
  final int amount;
}

class _ChartData {
  _ChartData({this.x, this.y});
  final String? x;
  final int? y;
}
