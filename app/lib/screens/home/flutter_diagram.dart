import 'dart:convert';

import 'package:app/screens/home/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart';

import '../../services/auth_service.dart';

class RealtimeDiagram extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<RealtimeDiagram> {
  late TooltipBehavior _tooltipBehavior;
  final AuthService _authService = AuthService();
  List<TransactionDetails> chartData = [];

  Future loadChartData() async {
    var snapShotsValue = await FirebaseFirestore.instance
        .collection("transactions")
        .where('uid', isEqualTo: _authService.getuser()!.uid)
        .get();
    List<TransactionDetails> list = snapShotsValue.docs
        .map(
            (e) => TransactionDetails(e.data()['category'], e.data()['amount']))
        .toList();
    setState(() {
      chartData = list;
    });
  }

  @override
  void initState() {
    loadChartData();
    _tooltipBehavior =
        TooltipBehavior(enable: true, tooltipPosition: TooltipPosition.pointer);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      drawer: NavDrawer(),
      body: SfCircularChart(
        series: <CircularSeries>[
          PieSeries<TransactionDetails, String>(
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                color: Colors.purple,
              ),
              dataSource: chartData,
              dataLabelMapper: (TransactionDetails details, _) =>
                  details.category,
              xValueMapper: (TransactionDetails details, _) => details.category,
              yValueMapper: (TransactionDetails details, _) => details.amount),
        ],
        tooltipBehavior: _tooltipBehavior,
      ),
    ));
  }
}

class TransactionDetails {
  TransactionDetails(this.category, this.amount);
  final String category;
  final int amount;

  factory TransactionDetails.fromJson(Map<String, dynamic> parsedJson) {
    return TransactionDetails(
        parsedJson['category'].toString(), parsedJson['amount']);
  }
}
