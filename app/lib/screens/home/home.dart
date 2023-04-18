import 'package:app/screens/home/transactions/create_transaction.dart';
import 'package:app/screens/home/menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class Xpt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    User? user = _authService.getuser();
    return Scaffold(
      drawer: NavDrawer(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('XPT - Track your money\n${_authService.getuser()!.email}'),
        backgroundColor: Color.fromARGB(255, 82, 144, 173),
        elevation: 0.0,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: ElevatedButton(
            child: Text(
              'This is your Expense Tracker Application. Create a transaction! ',
              style: TextStyle(color: Color.fromARGB(255, 17, 19, 20)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateTransaction()),
              );
              //return to create_transaction page
            }),
      ),
    );
  }
}
