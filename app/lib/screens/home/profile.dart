import 'package:app/screens/home/menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      theme: Theme.of(context),
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

            //TODO : do this as setstate

            TextFormField(
              controller: displayNameController,
              decoration: const InputDecoration(
                  icon: Icon(Icons.place_outlined), labelText: "Displayname"),
            ),
            ElevatedButton(
                onPressed: () {
                  user.updateDisplayName(displayNameController.text);
                },
                child: const Text("Call me in this name ")),
          ],
        ));
  }
}
