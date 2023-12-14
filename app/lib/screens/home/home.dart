import 'package:app/screens/home/diagram.dart';
import 'package:flutter/material.dart';

class Xpt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DiagramScreen(),
    );
  }
}
