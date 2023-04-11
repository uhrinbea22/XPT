import 'package:app/screens/home/menu.dart';
import 'package:app/screens/home/settings.dart';
import 'package:app/screens/home/transactions_detailview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

void main() {
  runApp(const ProfileScreen());
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: MyAppHomePage(title: 'Your profile'),
    );
  }
}

class MyAppHomePage extends StatelessWidget {
  MyAppHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  final displayNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    User? user = _authService.getuser();
    return Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text(title),
        ),
        body: Column(
          children: [
            Container(
              child: Text(user!.email.toString()),
            ),
            Text(user.displayName.toString()),
            //do this as setstate
            TextFormField(
              //editing controller of this TextField
              controller: displayNameController,
              decoration: const InputDecoration(
                  icon: Icon(Icons.place_outlined), //icon of text field
                  labelText: "Displayname" //label text of field
                  ),
            ),
            ElevatedButton(
                onPressed: () {
                  user.updateDisplayName(displayNameController.text);
                },
                child: Text("Call me this")),
            //put this in the main login page
            ElevatedButton(
                onPressed: () async {
                  final _status = await _authService.resetPassword(
                      email: user.email.toString());
                  if (_status == "success") {
                    print("Email sent");
                  } else {
                    print("error");
                  }
                },
                child: const Text("Reset pasword"))
          ],
        ));
  }
}
