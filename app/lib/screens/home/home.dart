import 'package:app/screens/home/create_transaction.dart';
import 'package:app/screens/home/list_of_categ.dart';
import 'package:app/screens/home/menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

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
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person),
            style: TextButton.styleFrom(
              backgroundColor: Colors.pink,
            ),
            label: Text('Sign out'),
            onPressed: () async {
              print(user.toString());
              await _authService.signOut();
            },
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: ElevatedButton(
            child: Text(
              'Welcome',
              style: TextStyle(color: Color.fromARGB(255, 17, 19, 20)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateTransacton()),
              );
              //return to create_transaction page
            }),
      ),
    );
  }
}
