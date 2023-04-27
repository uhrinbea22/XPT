import 'package:app/screens/home/diagram.dart';
import 'package:app/screens/home/transactions/create_transaction.dart';
import 'package:app/screens/home/menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class Xpt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Set this to false
      home: DiagramScreen(),
    );
  }
}
