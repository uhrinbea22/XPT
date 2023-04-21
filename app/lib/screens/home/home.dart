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
        home: const Home());
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
        title: Text("Üdvözöl a PénZen!"),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        //TODO
        // IDE EGYENLEG
        //BEVÉTELEK ÖSSZES
        //KIADÁSOK ÖSSZES
        //VÁRHATÓ KIADÁSOK - ELŐZŐ HÓNAPBÓL A SZÁMLÁK ÖSSZEGE
        //AJÁNLÁS A SZÁMLÁK HOZZÁADÁSÁRA ?
      ),
    );
  }
}
