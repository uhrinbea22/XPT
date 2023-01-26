import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('XPT - Track your money'),
        backgroundColor: Color.fromARGB(255, 82, 144, 173),
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person),
            style: TextButton.styleFrom(
              primary: Colors.pink,
            ),
            label: Text('Sign out'),
            onPressed: () async {
              await _authService.signOut();
            },
          )
        ],
      ),
    );
  }
}
