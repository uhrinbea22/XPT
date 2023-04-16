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
      home: ProfileStateful(),
    );
  }
}

class ProfileStateful extends StatefulWidget {
  @override
  MyCustomFormStat createState() {
    return MyCustomFormStat();
  }
}

class MyCustomFormStat extends State<ProfileStateful> {
  final String title = "";
  final displayNameController = TextEditingController();
  final AuthService _authService = AuthService();
  String resetPasswordStatus = "";

  @override
  Widget build(BuildContext context) {
    String? displayName = _authService.getuser()?.displayName;
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
            Text(displayName == null ? "Set a displayname" : displayName),

            //TODO : do this as setstate

            TextFormField(
              controller: displayNameController,
              decoration: const InputDecoration(
                  icon: Icon(Icons.face_outlined), labelText: "Displayname"),
            ),
            ElevatedButton(
                onPressed: () {
                  user.updateDisplayName(displayNameController.text);
                  setState(() {
                    displayName = displayNameController.text;
                  });
                },
                child: const Text("Call me in this name ")),
            ElevatedButton(
                onPressed: () async {
                  //send reset password email
                  final _status = await _authService.resetPassword(
                      email: user.email.toString());
                  if (_status) {
                    setState(() {
                      resetPasswordStatus = 'Email sent';
                    });
                  } else {
                    setState(() {
                      resetPasswordStatus = 'Error happened!';
                    });
                  }
                },
                child: const Text("Reset password")),
            Text(resetPasswordStatus)
          ],
        ));
  }
}
